// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

/// Retrieve a NodeInfo doc.
struct NodeInfoTarget {
    /// URL of the NodeInfo doc, from the JRD used to find it.
    let url: URL
}

extension NodeInfoTarget: Target {
    var baseURL: URL { url }
    var pathComponents: [String] { [] }
    var method: HTTP.HTTPMethod { .get }
    var queryParameters: [URLQueryItem] { [] }
    var jsonBody: [String : Any]? { nil }
    var multipartFormData: [String : HTTP.MultipartFormValue]? { nil }
    var headers: [String : String]? { ["Accept": "application/json"] }
}

extension NodeInfoTarget: DecodableTarget {
    typealias ResultType = NodeInfo
}
