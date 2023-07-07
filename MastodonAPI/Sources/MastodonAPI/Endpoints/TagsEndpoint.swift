// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum TagsEndpoint {
    /// https://docs.joinmastodon.org/methods/trends/#tags
    case trends(limit: Int? = nil, offset: Int? = nil)
    /// https://docs.joinmastodon.org/methods/followed_tags/#get
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

    public var requires: APICapabilityRequirements? {
        switch self {
        case .trends:
            return [
                .mastodon: "3.5.0",
                .hometown: "3.5.0"
            ]
        case .followed:
            return [
                .mastodon: "4.0.0",
                .hometown: "4.0.0"
            ]
        }
    }

    public var fallback: [Tag]? { [] }
}
