// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import Mastodon

public struct CardViewModel {
    private let card: Card

    init(card: Card) {
        self.card = card
    }
}

public extension CardViewModel {
    var url: URL { card.url.url }

    var displayHost: String? {
        if let host = url.host, host.hasPrefix("www."),
           let withoutWww = host.components(separatedBy: "www.").last {
            return withoutWww
        } else {
            return url.host
        }
    }

    var title: String { card.title }

    var description: String { card.description }

    var imageURL: URL? { card.image?.url }
}

extension CardViewModel: Trendable {
    public var history: [History]? { card.history }
}
