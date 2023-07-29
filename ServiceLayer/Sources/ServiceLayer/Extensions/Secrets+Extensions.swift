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
                ),
                compatibilityMode: getAPICompatibilityMode()
            )
            .withDetectedFeatures(getAPIFeatures())
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
        try setAPIFeatures(apiCapabilities.features)
        try setAPICompatibilityMode(apiCapabilities.compatibilityMode)
    }

    func getAPIFeatures() -> Set<APIFeature> {
        do {
            let rawValues = try getAPIFeaturesRawValues()
            let z = rawValues.compactMap { APIFeature(rawValue: $0) }
            return .init(z)
        } catch {
            return .init()
        }
    }

    func setAPIFeatures(_ features: Set<APIFeature>) throws {
        try setAPIFeaturesRawValues(features.map(\.rawValue))
    }

    func getAPICompatibilityMode() -> APICompatibilityMode? {
        do {
            return .init(rawValue: try getAPICompatibilityModeRawValue())
        } catch {
            return nil
        }
    }

    func setAPICompatibilityMode(_ apiCompatibilityMode: APICompatibilityMode?) throws {
        try setAPICompatibilityModeRawValue(apiCompatibilityMode?.rawValue ?? "")
    }
}
