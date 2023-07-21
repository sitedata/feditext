// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation
import Mastodon
import Semver

/// Capabilities of the exact server we're talking to, taking into account API flavor and version.
public struct APICapabilities: Encodable {
    public let flavor: APIFlavor?
    public let version: Semver?
    public let compatibilityMode: APICompatibilityMode?
    private let nodeinfoSoftware: NodeInfo.Software

    public init(
        flavor: APIFlavor? = nil,
        version: Semver? = nil,
        compatibilityMode: APICompatibilityMode? = nil,
        nodeinfoSoftware: NodeInfo.Software
    ) {
        self.flavor = flavor
        self.version = version
        self.compatibilityMode = compatibilityMode
        self.nodeinfoSoftware = nodeinfoSoftware
    }

    /// Init from the mandatory software object of a NodeInfo doc.
    public init(
        nodeinfoSoftware: NodeInfo.Software,
        compatibilityMode: APICompatibilityMode? = nil
    ) {
        let version = nodeinfoSoftware.version
            .split(separator: " ", maxSplits: 1)
            .first
            .flatMap { Semver(String($0)) }
        self.init(
            flavor: .init(rawValue: nodeinfoSoftware.name),
            version: version,
            compatibilityMode: compatibilityMode,
            nodeinfoSoftware: nodeinfoSoftware
        )
    }

    /// Init from a NodeInfo doc.
    public init(
        nodeInfo: NodeInfo,
        compatibilityMode: APICompatibilityMode? = nil
    ) {
        self.init(
            nodeinfoSoftware: nodeInfo.software,
            compatibilityMode: compatibilityMode
        )
    }
}

/// Requirements to make an API call.
public struct APICapabilityRequirements {
    private let minVersions: [APIFlavor: Semver]

    /// Does the given server's capabilities match our requirements?
    /// Assume that, if we don't have a minimum version for a given flavor, that flavor is *not* supported.
    public func satisfiedBy(_ apiCapabilities: APICapabilities) -> Bool {
        guard let flavor = apiCapabilities.flavor,
              let version = apiCapabilities.version,
              let minVersion = minVersions[flavor] else {
            return false
        }
        return version >= minVersion
    }
}

extension APICapabilityRequirements: ExpressibleByDictionaryLiteral {
    public typealias Key = APIFlavor
    public typealias Value = Semver

    public init(dictionaryLiteral elements: (APIFlavor, Semver)...) {
        minVersions = .init(uniqueKeysWithValues: elements)
    }
}

public extension Semver {
    /// We don't know which version added this, but assume it's available.
    static let assumeAvailable: Semver = "0.0.0"
}
