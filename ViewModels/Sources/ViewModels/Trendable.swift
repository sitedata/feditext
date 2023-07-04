// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import Mastodon

/// Can have trend history attached.
public protocol Trendable {
    var history: [History]? { get }
}

public extension Trendable {
    var accounts: Int? {
        guard let history = history,
              var accounts = history.first?.accounts
        else { return nil }

        if history.count > 1 {
            accounts += history[1].accounts
        }

        return accounts
    }

    var uses: Int? {
        guard let history = history,
              var uses = history.first?.uses
        else { return nil }

        if history.count > 1 {
            uses += history[1].uses
        }

        return uses
    }

    var usageHistory: [Int] {
        history?.compactMap { Int($0.uses) } ?? []
    }

    var accountsText: String? {
        guard let accounts = accounts else { return nil }
        return String.localizedStringWithFormat(
            NSLocalizedString("tag.people-talking-%ld", comment: ""),
            accounts
        )
    }

    var accessibilityAccountsText: String? { accountsText }

    var recentUsesText: String? {
        guard let uses = uses else { return nil }
        return String(uses)
    }

    var accessibilityRecentUsesText: String? {
        guard let uses = uses else { return nil }
        return String.localizedStringWithFormat(
            NSLocalizedString("tag.accessibility-recent-uses-%ld", comment: ""),
            uses
        )
    }
}
