// Copyright © 2023 Vyr Cossont. All rights reserved.

import Combine
import Foundation
import Mastodon
import MastodonAPI
import Secrets

extension APICapabilities {
    /// Get API capabilities from NodeInfo and instance APIs, and as a side effect, store them in the secret store.
    /// (They're not secret, but that's where we keep other rarely changing values needed by the API client,
    /// like the instance URL.)
    static func refresh(
        session: URLSession,
        instanceURL: URL,
        secrets: Secrets
    ) -> AnyPublisher<APICapabilities, Error> {
        NodeInfoClient(session: session, instanceURL: instanceURL)
            .nodeInfo()
            .map { nodeInfo in
                APICapabilities(
                    nodeInfo: nodeInfo,
                    compatibilityMode: secrets.getAPICompatibilityMode()
                )
            }
            .flatMap { apiCapabilities in
                MastodonAPIClient(
                    session: session,
                    instanceURL: instanceURL,
                    apiCapabilities: apiCapabilities
                )
                .request(InstanceEndpoint.instance)
                    .map { instance in
                        var features = Set<APIFeature>()

                        if instance.configuration?.reactions != nil {
                            features.insert(.emojiReactions)
                        }

                        try? secrets.setAPICapabilities(apiCapabilities.withDetectedFeatures(features))
                        return apiCapabilities
                    }
            }
            .eraseToAnyPublisher()
    }
}
