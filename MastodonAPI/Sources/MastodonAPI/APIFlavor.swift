// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation

/// Type of Mastodon-compatible-ish Fediverse server that we're talking to.
/// String value currently identical to `NodeInfo.software.name` for known servers.
public enum APIFlavor: String, Codable, Hashable {
    case mastodon
    case hometown

    case pleroma
    case akkoma

    case gotosocial

    case calckey
}
