// Copyright © 2023 Vyr Cossont. All rights reserved.

/// Encapsulates actions we can do that are related to a timeline
/// and need to show UI for in a collection view.
public enum TimelineActionViewModel {
    case context(ContextTimelineActionViewModel)
    case tag(TagTimelineActionViewModel)
    case list(ListTimelineActionViewModel)
    case displayFilter(DisplayFilterTimelineActionViewModel)

    static func from(
        timeline: Timeline,
        identityContext: IdentityContext,
        collectionItemsViewModel: CollectionItemsViewModel
    ) -> Self? {
        switch timeline {
        case let .tag(name):
            return .tag(
                TagTimelineActionViewModel(
                    name: name,
                    identityContext: identityContext,
                    collectionItemsViewModel: collectionItemsViewModel
                )
            )
        case let .list(list):
            return .list(
                ListTimelineActionViewModel(
                    list: list,
                    identityContext: identityContext
                )
            )
        case .home, .local, .federated:
            return .displayFilter(
                DisplayFilterTimelineActionViewModel()
            )
        default:
            return nil
        }
    }
}
