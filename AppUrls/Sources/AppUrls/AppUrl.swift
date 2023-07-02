// Copyright © 2023 Vyr Cossont. All rights reserved.

import Foundation

/// Parse or construct `feditext:` URLs, used by the action extension and for some internal navigation.
/// `feditext:` URLs should never appear in HTML unless we put them there post-HTML-parsing.
public enum AppUrl {
    private static let scheme: String = "feditext"

    case search(_ searchUrl: URL)
    private static let searchPath: String = "search"
    private static let searchUrlParam: String = "url"

    case tagTimeline(_ name: String)
    private static let timelinePath: String = "timeline"
    private static let timelineTagParam: String = "tag"

    case mention(_ userUrl: URL)
    private static let mentionPath: String = "mention"
    private static let mentionUrlParam: String = "url"

    public init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == Self.scheme,
              let queryItems = components.queryItems else {
            return nil
        }

        let params: [String: String] = Dictionary(
            queryItems.compactMap { item in
                item.value.map { value in
                    (item.name, value)
                }
            },
            uniquingKeysWith: { (key, _) in key }
        )

        switch components.path {
        case Self.searchPath:
            if let value = params[Self.searchUrlParam],
               let searchUrl = URL(string: value) {
                self = .search(searchUrl)
                return
            }

        case Self.timelinePath:
            if let name = params[Self.timelineTagParam] {
                self = .tagTimeline(name)
                return
            }

        case Self.mentionPath:
            if let value = params[Self.mentionUrlParam],
               let userUrl = URL(string: value) {
                self = .mention(userUrl)
                return
            }

        default:
            break
        }

        return nil
    }

    public var url: URL {
        switch self {
        case let .search(url):
            return Self.makeUrl(
                url,
                path: Self.searchPath,
                param: Self.searchUrlParam,
                stringify: { $0.absoluteString }
            )

        case let .tagTimeline(name):
            return Self.makeUrl(
                name,
                path: Self.timelinePath,
                param: Self.timelineTagParam,
                stringify: { $0 }
            )

        case let .mention(url):
            return Self.makeUrl(
                url,
                path: Self.mentionPath,
                param: Self.mentionUrlParam,
                stringify: { $0.absoluteString }
            )
        }
    }

    private static func makeUrl<T>(
        _ value: T,
        path: String,
        param: String,
        stringify: (T) -> String
    ) -> URL {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = Self.scheme
        urlBuilder.path = path
        urlBuilder.queryItems = [.init(name: param, value: stringify(value))]
        guard let result = urlBuilder.url else {
            fatalError("Building a basic app URL should always succeed")
        }
        return result
    }
}
