// Copyright © 2023 Vyr Cossont. All rights reserved.

import MastodonAPI
import SwiftUI

public struct APICapabilitiesViewModel {
    private let apiCapabilities: APICapabilities

    public init(apiCapabilities: APICapabilities) {
        self.apiCapabilities = apiCapabilities
    }

    public var localizedName: LocalizedStringKey? {
        switch apiCapabilities.flavor {
        case .none:
            return nil
        case .mastodon:
            return "flavor.mastodon.name"
        case .hometown:
            return "flavor.hometown.name"
        case .pleroma:
            return "flavor.pleroma.name"
        case .akkoma:
            return "flavor.akkoma.name"
        case .gotosocial:
            return "flavor.gotosocial.name"
        case .calckey:
            return "flavor.calckey.name"
        case .firefish:
            return "flavor.firefish.name"
        }
    }

    public var homepage: URL? {
        switch apiCapabilities.flavor {
        case .none:
            return nil
        case .mastodon:
            return URL(string: "https://joinmastodon.org/")
        case .hometown:
            return URL(string: "https://github.com/hometown-fork/hometown")
        case .pleroma:
            return URL(string: "https://pleroma.social/")
        case .akkoma:
            return URL(string: "https://akkoma.social/")
        case .gotosocial:
            return URL(string: "https://gotosocial.org/")
        case .calckey:
            return URL(string: "https://calckey.org/")
        case .firefish:
            return URL(string: "https://joinfirefish.org/")
        }
    }

    public var version: String? { apiCapabilities.version?.description }
}
