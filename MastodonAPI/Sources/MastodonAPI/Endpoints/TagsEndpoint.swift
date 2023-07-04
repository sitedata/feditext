// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum TagsEndpoint {
    case trends(limit: Int? = nil, offset: Int? = nil)
    case followed
}

extension TagsEndpoint: Endpoint {
    public typealias ResultType = [Tag]

    public var pathComponentsInContext: [String] {
        switch self {
        case .trends: return ["trends", "tags"]
        case .followed: return ["followed_tags"]
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .trends, .followed: return .get
        }
    }

    public var queryParameters: [URLQueryItem] {
        switch self {
        case let .trends(limit, offset):
            return queryParameters(limit, offset)
        case .followed:
            return []
        }
    }
}
