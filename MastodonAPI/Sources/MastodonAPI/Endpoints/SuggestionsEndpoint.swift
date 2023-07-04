// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

public enum SuggestionsEndpoint {
    case suggestions(limit: Int? = nil)
}

extension SuggestionsEndpoint: Endpoint {
    public typealias ResultType = [Suggestion]
    public var pathComponentsInContext: [String] { ["suggestions"] }
    public var method: HTTPMethod { .get }
    public var APIVersion: String { "v2" }

    public var queryParameters: [URLQueryItem] {
        switch self {
        case let .suggestions(limit):
            return queryParameters(limit, nil)
        }
    }
}
