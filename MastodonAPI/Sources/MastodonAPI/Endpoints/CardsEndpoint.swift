// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum CardsEndpoint {
    case trends(limit: Int? = nil, offset: Int? = nil)
}

extension CardsEndpoint: Endpoint {
    public typealias ResultType = [Card]

    public var pathComponentsInContext: [String] {
        switch self {
        case .trends: return ["trends", "links"]
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .trends: return .get
        }
    }

    public var queryParameters: [URLQueryItem] {
        switch self {
        case let .trends(limit, offset):
            return queryParameters(limit, offset)
        }
    }
}
