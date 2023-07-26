// Copyright © 2023 Vyr Cossont. All rights reserved.

import Combine
import ServiceLayer

/// Settings for post-fetch filtering of collection items.
public final class DisplayFilterTimelineActionViewModel: ObservableObject {
    @Published public var showBots: Bool = true
    @Published public var showReblogs: Bool = true
    @Published public var showReplies: Bool = true

    @Published private(set) public var filtering = false
    @Published private(set) public var displayFilter: DisplayFilter = .init()

    public init() {
        self.showBots = displayFilter.showBots
        self.showReblogs = displayFilter.showReblogs
        self.showReplies = displayFilter.showReplies

        $showBots
            .combineLatest($showReblogs, $showReplies) { showBots, showReblogs, showReplies in
                .init(showBots: showBots, showReblogs: showReblogs, showReplies: showReplies)
            }
            .assign(to: &$displayFilter)

        $displayFilter
            .map(\.filtering)
            .assign(to: &$filtering)
    }
}
