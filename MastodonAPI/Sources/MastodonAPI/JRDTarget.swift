// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

/// Retrieve a JRD doc.
struct JRDTarget {
    /// Base URL of the Fedi server instance.
    let instanceURL: URL
}

extension JRDTarget: Target {
    var baseURL: URL { instanceURL }
    var pathComponents: [String] { [".well-known", "nodeinfo"] }
    var method: HTTP.HTTPMethod { .get }
    var queryParameters: [URLQueryItem] { [] }
    var jsonBody: [String: Any]? { nil }
    var multipartFormData: [String: HTTP.MultipartFormValue]? { nil }
    var headers: [String: String]? { ["Accept": "application/json"] }
}

extension JRDTarget: DecodableTarget {
    typealias ResultType = JRD
}
