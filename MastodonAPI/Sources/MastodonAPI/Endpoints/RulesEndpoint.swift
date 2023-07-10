// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum RulesEndpoint {
    /// https://docs.joinmastodon.org/methods/instance/#rules
    case rules
}

extension RulesEndpoint: Endpoint {
    public typealias ResultType = [Rule]

    public var context: [String] {
        defaultContext + ["instance/rules"]
    }

    public var pathComponentsInContext: [String] {
        switch self {
        case .rules:
            return []
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .rules:
            return .get
        }
    }

    public var requires: APICapabilityRequirements? {
        [
            .mastodon: "3.4.0",
            .hometown: "3.4.0"
        ]
    }

    public var fallback: [Rule]? { [] }
}
