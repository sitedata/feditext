// Copyright © 2023 Vyr Cossont. All rights reserved.

import MastodonAPI
import os
import Secrets

extension Secrets {
    func getAPICapabilities() -> APICapabilities {
        do {
            return .init(
                nodeinfoSoftware: .init(
                    name: try getSoftwareName(),
                    version: try getSoftwareVersion()
                )
            )
        } catch {
            // This should only happen with old versions of the secret store that predate NodeInfo detection.
            // In this case, it's okay to return a default; something will call refreshAPICapabilities soon.
            Logger().warning("API capabilities missing from Secrets, falling back to unknown capabilities")
            return .init(
                nodeinfoSoftware: .init(
                    name: "",
                    version: ""
                )
            )
        }
    }

    func setAPICapabilities(_ apiCapabilities: APICapabilities) throws {
        try setSoftwareName(apiCapabilities.flavor?.rawValue ?? "")
        try setSoftwareVersion(apiCapabilities.version?.description ?? "")
    }
}
