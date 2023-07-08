// Copyright © 2023 Vyr Cossont. All rights reserved.

import Combine
import Mastodon

/// Things we can do to a list: update its title, replies policy, and exclusive flag.
public final class ListTimelineActionViewModel: ObservableObject {
    @Published public private(set) var list: List

    private let identityContext: IdentityContext
    private weak var collectionItemsViewModel: CollectionItemsViewModel?

    public init(
        list: List,
        identityContext: IdentityContext,
        collectionItemsViewModel: CollectionItemsViewModel
    ) {
        self.list = list
        self.identityContext = identityContext
        self.collectionItemsViewModel = collectionItemsViewModel
    }

    public var editListViewModel: EditListViewModel {
        EditListViewModel(list: list, identityContext: identityContext)
    }
}
