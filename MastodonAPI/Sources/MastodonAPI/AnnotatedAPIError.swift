// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import HTTP
import Mastodon

/// Thrown when an API call fails but returns a decodable Mastodon API error instead of a lower-level one.
public struct AnnotatedAPIError: Error, AnnotatedError, LocalizedError, Encodable {
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
        let request = target.urlRequest()
        guard let method = request.httpMethod, let url = request.url else { return nil }
        self.init(
            apiError: apiError,
            method: method,
            url: url,
            statusCode: response.statusCode,
            requestLocation: requestLocation,
            apiCapabilities: apiCapabilities
        )
    }

    public var errorDescription: String? {
        return "\(method) \(url.absoluteString)\n\n\(apiError.error)"
    }

    public var failQuietly: Bool { false }
}
