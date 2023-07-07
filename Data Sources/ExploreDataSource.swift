// Copyright © 2021 Metabolist. All rights reserved.

import Combine
import Mastodon
import MastodonAPI
import UIKit
import ViewModels

final class ExploreDataSource: UICollectionViewDiffableDataSource<ExploreViewModel.Section, ExploreViewModel.Item> {
    private let updateQueue =
        DispatchQueue(label: "com.metabolist.metatext.explore-data-source.update-queue")
    private weak var collectionView: UICollectionView?
    private let identityContext: IdentityContext
    private var cancellables = Set<AnyCancellable>()

    init(collectionView: UICollectionView, viewModel: ExploreViewModel) {
        self.collectionView = collectionView
        self.identityContext = viewModel.identityContext

        let tagRegistration = UICollectionView.CellRegistration<TagCollectionViewCell, TagViewModel> {
            $0.viewModel = $2
        }

        let linkRegistration = UICollectionView.CellRegistration<CardCollectionViewCell, CardViewModel> {
            $0.viewModel = $2
        }

        let statusRegistration = UICollectionView.CellRegistration<StatusCollectionViewCell, StatusViewModel> {
            $0.viewModel = $2
        }

        let instanceRegistration = UICollectionView.CellRegistration<InstanceCollectionViewCell, InstanceViewModel> {
            $0.viewModel = $2
        }

        let itemRegistration = UICollectionView.CellRegistration
        <SeparatorConfiguredCollectionViewListCell, ExploreViewModel.Item> {
            var configuration = $0.defaultContentConfiguration()

            switch $2 {
            case .profileDirectory:
                configuration.text = NSLocalizedString("explore.profile-directory", comment: "")
                configuration.image = UIImage(systemName: "person.crop.square.fill.and.at.rectangle")
            case .suggestedAccounts:
                configuration.text = NSLocalizedString("explore.suggested-accounts", comment: "")
                configuration.image = UIImage(systemName: "person.line.dotted.person.fill")
            default:
                break
            }

            $0.contentConfiguration = configuration
            $0.accessories = [.disclosureIndicator()]
        }

        super.init(collectionView: collectionView) {
            switch $2 {
            case let .tag(tag):
                return $0.dequeueConfiguredReusableCell(
                    using: tagRegistration,
                    for: $1,
                    item: viewModel.viewModel(tag: tag))
            case let .link(card):
                return $0.dequeueConfiguredReusableCell(
                    using: linkRegistration,
                    for: $1,
                    item: viewModel.viewModel(card: card))
            case let .status(status):
                return $0.dequeueConfiguredReusableCell(
                    using: statusRegistration,
                    for: $1,
                    item: viewModel.viewModel(status: status))
            case .instance:
                return $0.dequeueConfiguredReusableCell(
                    using: instanceRegistration,
                    for: $1,
                    item: viewModel.instanceViewModel)
            default:
                return $0.dequeueConfiguredReusableCell(using: itemRegistration, for: $1, item: $2)
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration
        <ExploreSectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] in
            $0.label.text = self?.snapshot().sectionIdentifiers[$2.section]
                .displayName(viewModel.identityContext.appPreferences.statusWord)
        }

        supplementaryViewProvider = {
            $0.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: $2)
        }

        viewModel.$instanceViewModel.combineLatest(viewModel.$tags, viewModel.$links, viewModel.$statuses)
            .sink { [weak self] in self?.update(instanceViewModel: $0, tags: $1, links: $2, statuses: $3) }
            .store(in: &cancellables)
    }

    override func apply(_ snapshot: NSDiffableDataSourceSnapshot<ExploreViewModel.Section, ExploreViewModel.Item>,
                        animatingDifferences: Bool = true,
                        completion: (() -> Void)? = nil) {
        updateQueue.async {
            super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        }
    }
}

private extension ExploreDataSource {
    func update(instanceViewModel: InstanceViewModel?, tags: [Tag], links: [Card], statuses: [Status]) {
        var newsnapshot = NSDiffableDataSourceSnapshot<ExploreViewModel.Section, ExploreViewModel.Item>()

        // TODO: (Vyr) move directory and suggetions to their own tab or secondary nav.
        var instanceSectionItems = [ExploreViewModel.Item]()

        if AccountsEndpoint.directory(local: false).canCallWith(identityContext.apiCapabilities) {
            instanceSectionItems.append(.profileDirectory)
        }

        if SuggestionsEndpoint.suggestions().canCallWith(identityContext.apiCapabilities) {
            instanceSectionItems.append(.suggestedAccounts)
        }

        // Use the `.instance` item as a fallback for decoration on instances that don't support trends or suggestions.
        // TODO: (Vyr) roll this into `AboutInstanceView`.
        if instanceSectionItems.isEmpty && tags.isEmpty && links.isEmpty && statuses.isEmpty,
            instanceViewModel != nil {
            instanceSectionItems.append(.instance)
        }

        if !instanceSectionItems.isEmpty {
            newsnapshot.appendSections([.instance])
            newsnapshot.appendItems(instanceSectionItems, toSection: .instance)
        }

        if !tags.isEmpty {
            newsnapshot.appendSections([.tags])
            newsnapshot.appendItems(tags.map(ExploreViewModel.Item.tag), toSection: .tags)
        }

        if !links.isEmpty {
            newsnapshot.appendSections([.links])
            newsnapshot.appendItems(links.map(ExploreViewModel.Item.link), toSection: .links)
        }

        if !statuses.isEmpty {
            newsnapshot.appendSections([.statuses])
            newsnapshot.appendItems(statuses.map(ExploreViewModel.Item.status), toSection: .statuses)
        }

        let wasEmpty = self.snapshot().itemIdentifiers.isEmpty
        let contentOffset = collectionView?.contentOffset

        apply(newsnapshot, animatingDifferences: false) {
            if let contentOffset = contentOffset, !wasEmpty {
                self.collectionView?.contentOffset = contentOffset
            }
        }
    }
}

private extension ExploreViewModel.Section {
    func displayName(_ statusWord: AppPreferences.StatusWord) -> String {
        switch self {
        case .tags:
            return NSLocalizedString("explore.trending.tags", comment: "")
        case .links:
            return NSLocalizedString("explore.trending.links", comment: "")
        case .statuses:
            switch statusWord {
            case .post:
                return NSLocalizedString("explore.trending.statuses.post", comment: "")
            case .toot:
                return NSLocalizedString("explore.trending.statuses.toot", comment: "")
            }
        case .instance:
            return NSLocalizedString("explore.instance", comment: "")
        }
    }
}
