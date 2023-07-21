// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

/// Thrown when an API is not available according to detected server software and version.
public struct AnnotatedAPIError: Error, LocalizedError, Encodable {
    public let apiError: APIError
    public let method: String
    public let url: URL
    public let statusCode: Int
    public let requestLocation: DebugLocation
    public let apiCapabilities: APICapabilities

    public init(
        apiError: APIError,
        method: String,
        url: URL,
        statusCode: Int,
        requestLocation: DebugLocation,
        apiCapabilities: APICapabilities
    ) {
        self.apiError = apiError
        self.method = method
        self.url = url
        self.statusCode = statusCode
        self.requestLocation = requestLocation
        self.apiCapabilities = apiCapabilities
    }

    public init?(
        apiError: APIError,
        target: Target,
        response: HTTPURLResponse,
        requestLocation: DebugLocation,
        apiCapabilities: APICapabilities
    ) {
        self.apiError = apiError
        let request = target.urlRequest()
        guard let method = request.httpMethod, let url = request.url else { return nil }
        self.method = method
        self.url = url
        self.statusCode = response.statusCode
        self.requestLocation = requestLocation
        self.apiCapabilities = apiCapabilities
    }

    public var errorDescription: String? {
        return "\(method) \(url.absoluteString)\n\n\(apiError.error)"
    }
}
