// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation

/// Type of Mastodon-compatible-ish Fediverse server that we're talking to.
/// String value currently identical to `NodeInfo.software.name` for known servers.
///
/// - https://docs.joinmastodon.org/
/// - https://api.pleroma.social/
/// - https://docs.akkoma.dev/stable/development/API/differences_in_mastoapi_responses/
/// - https://docs.gotosocial.org/en/latest/api/swagger/
/// - https://calckey.social/api-doc (not clear if this lists Mastodon-compatible API methods yet)
public enum APIFlavor: String, Codable, Hashable, Identifiable, CaseIterable {
    case mastodon
    case hometown

    case pleroma
    case akkoma

    case gotosocial

    case calckey
    case firefish

    public var id: Self { self }
}
