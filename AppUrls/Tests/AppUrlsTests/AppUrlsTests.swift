// Copyright © 2023 Vyr Cossont. All rights reserved.

@testable import AppUrls
import XCTest

final class AppUrlsTests: XCTestCase {
    func testMakeTagTimeline() throws {
        XCTAssertEqual(
            AppUrl.makeTagTimeline(name: "hashtag").absoluteString,
            "feditext:timeline?tag=hashtag"
        )
    }
}
