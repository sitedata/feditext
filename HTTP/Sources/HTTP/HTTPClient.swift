// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import Foundation

open class HTTPClient {
    public let decoder: JSONDecoder

    private let session: URLSession

    public init(session: URLSession, decoder: JSONDecoder) {
        self.session = session
        self.decoder = decoder
    }

    open func dataTaskPublisher<T: DecodableTarget>(
        _ target: T,
        progress: Progress? = nil,
        requestLocation: DebugLocation
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        if let protocolClasses = session.configuration.protocolClasses {
            for protocolClass in protocolClasses {
                (protocolClass as? TargetProcessing.Type)?.process(target: target)
            }
        }

        return session.dataTaskPublisher(for: target.urlRequest(), progress: progress)
            .mapError { error in
                if let urlError = error as? URLError,
                   let annotatedUrlError = AnnotatedURLError(
                    urlError: urlError, target: target, requestLocation: requestLocation
                   ) {
                    return annotatedUrlError as Error
                }
                return error
            }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HTTPError(
                        target: target,
                        requestLocation: requestLocation
                    )
                }

                guard Self.validStatusCodes.contains(httpResponse.statusCode) else {
                    throw HTTPError(
                        target: target,
                        data: data,
                        httpResponse: httpResponse,
                        requestLocation: requestLocation
                    )
                }

                return (data, httpResponse)
            }
            .eraseToAnyPublisher()
    }

    open func request<T: DecodableTarget>(
        _ target: T,
        progress: Progress? = nil,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) -> AnyPublisher<T.ResultType, Error> {
        let requestLocation = DebugLocation(file: file, line: line, function: function)

        return dataTaskPublisher(
            target,
            progress: progress,
            requestLocation: requestLocation
        )
            .map(\.data)
            .decode(type: T.ResultType.self, decoder: decoder)
            .mapError { error in
                if let decodingError = error as? DecodingError,
                   let annotatedDecodingError = AnnotatedDecodingError(
                    decodingError: decodingError,
                    target: target,
                    requestLocation: requestLocation
                   ) {
                    return annotatedDecodingError as Error
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}

public extension HTTPClient {
    static let validStatusCodes = 200..<300
}
