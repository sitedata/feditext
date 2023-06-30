// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation

/// Constants used by `feditext:` URLs.
public enum AppUrls {
    public static let scheme: String = "feditext"

    public static let searchPath: String = "search"
    public static let searchUrlParam: String = "url"

    public static let timelinePath: String = "timeline"
    public static let timelineTagParam: String = "tag"

    public static let mentionPath: String = "mention"
    public static let mentionUrlParam: String = "url"

    public static func makeTagTimeline(name: String) -> URL {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = Self.scheme
        urlBuilder.path = Self.timelinePath
        urlBuilder.queryItems = [.init(name: Self.timelineTagParam, value: name)]
        guard let result = urlBuilder.url else {
            fatalError("Building a tag timeline URL should always succeed")
        }
        return result
    }

    public static func makeMention(url: URL) -> URL {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = Self.scheme
        urlBuilder.path = Self.timelinePath
        urlBuilder.queryItems = [.init(name: Self.mentionUrlParam, value: url.absoluteString)]
        guard let result = urlBuilder.url else {
            fatalError("Building a user mention URL should always succeed")
        }
        return result
    }
}
