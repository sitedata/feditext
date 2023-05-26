// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum FamiliarFollowersEndpoint {
    case familiarFollowers(ids: [Account.Id])
}

extension FamiliarFollowersEndpoint: Endpoint {
    public typealias ResultType = [FamiliarFollowers]

    public var context: [String] {
        return defaultContext + ["accounts", "familiar_followers"]
    }

    public var pathComponentsInContext: [String] {
        []
    }

    public var method: HTTPMethod {
        .get
    }

    public var queryParameters: [URLQueryItem] {
        switch self {
        case let .familiarFollowers(ids):
            return ids.map { URLQueryItem(name: "id[]", value: $0) }
        }
    }
}
