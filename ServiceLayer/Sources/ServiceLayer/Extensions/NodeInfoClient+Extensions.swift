// Copyright © 2023 Vyr Cossont. All rights reserved.

import Combine
import MastodonAPI
import Secrets

extension NodeInfoClient {
    /// Get API capabilities from NodeInfo, and as a side effect, store them in the secret store.
    /// (They're not secret, but that's where we keep other rarely changing values needed by the API client,
    /// like the instance URL.)
    func refreshAPICapabilities(secrets: Secrets) -> AnyPublisher<APICapabilities, Error> {
        nodeInfo()
            .flatMap { nodeInfo in
                let apiCapabilities = APICapabilities(
                    nodeInfo: nodeInfo,
                    compatibilityMode: secrets.getAPICompatibilityMode()
                )
                do {
                    try secrets.setAPICapabilities(apiCapabilities)
                } catch {
                    return Fail<APICapabilities, Error>(error: error).eraseToAnyPublisher()
                }
                return Just(apiCapabilities).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
