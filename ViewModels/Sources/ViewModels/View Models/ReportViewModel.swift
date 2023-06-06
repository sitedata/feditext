// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Foundation
import Mastodon
import ServiceLayer

public final class ReportViewModel: CollectionItemsViewModel {
    @Published public var elements: ReportElements
    @Published public private(set) var reportingState = ReportingState.composing
    @Published public private(set) var rules: [Rule] = []
    @Published public private(set) var categories: [Report.Category] = ReportViewModel.categoriesFor(rules: [])

    private let accountService: AccountService
    private var cancellables = Set<AnyCancellable>()

    public init(accountService: AccountService, statusId: Status.Id? = nil, identityContext: IdentityContext) {
        self.accountService = accountService
        self.elements = ReportElements(accountId: accountService.account.id)

        super.init(
            collectionService: identityContext.service.navigationService.timelineService(
                timeline: .profile(
                    accountId: accountService.account.id,
                    profileCollection: .statusesAndBoosts
                )
            ),
            identityContext: identityContext
        )

        identityContext.service
            .rulesPublisher()
            .receive(on: DispatchQueue.main)
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .assign(to: &$rules)

        $rules
            .map { Self.categoriesFor(rules: $0) }
            .assign(to: &$categories)

        identityContext.service
            .refreshRules()
            .assignErrorsToAlertItem(to: \.alertItem, on: self)
            .sink { _ in }
            .store(in: &cancellables)

        if let statusId = statusId {
            elements.statusIds.insert(statusId)
        }
    }

    public override func viewModel(indexPath: IndexPath) -> Any {
        let viewModel = super.viewModel(indexPath: indexPath)

        if let statusViewModel = viewModel as? StatusViewModel {
            statusViewModel.showReportSelectionToggle = true
            statusViewModel.selectedForReport = elements.statusIds.contains(statusViewModel.id)
        }

        return viewModel as Any
    }

    private static func categoriesFor(rules: [Rule]) -> [Report.Category] {
        Report.Category
            .allCasesExceptUnknown
            // Hide the rules violation category if the instance doesn't have any rules.
            .filter { $0 != .violation || !rules.isEmpty }
    }
}

public extension ReportViewModel {
    enum ReportingState {
        case composing
        case reporting
        case done
    }

    var accountName: String { "@".appending(accountService.account.acct) }

    var accountHost: String {
        URL(string: accountService.account.url)?.host ?? ""
    }

    var isLocalAccount: Bool { accountService.isLocal }

    func report() {
        accountService.report(elements)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.reportingState = .reporting })
            .sink { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .finished:
                    self.reportingState = .done
                case let .failure(error):
                    self.alertItem = AlertItem(error: error)
                    self.reportingState = .composing
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

public extension ReportElements {
    var canSubmit: Bool {
        if category == .violation {
            // If reporting a rule violation, the user must pick at least one rule.
            return !ruleIDs.isEmpty
        }
        return category != nil
    }
}
