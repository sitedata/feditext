// Copyright © 2023 Vyr Cossont. All rights reserved.

import MastodonAPI
import Secrets
import os

extension Secrets {
    func getAPICapabilities() -> APICapabilities {
        do {
            return APICapabilities(
                softwareName: try getSoftwareName(),
                softwareVersion: try getSoftwareVersion()
            )
        } catch {
            // This should only happen with old versions of the secret store that predate NodeInfo detection.
            // In this case, it's okay to return a default; something will call refreshAPICapabilities soon.
            Logger().warning("API capabilities missing from Secrets, falling back to unknown capabilities")
            return .init()
        }
    }

    func setAPICapabilities(_ apiCapabilities: APICapabilities) throws {
        try setSoftwareName(apiCapabilities.flavor?.rawValue ?? "")
        try setSoftwareVersion(apiCapabilities.version?.description ?? "")
    }
}
