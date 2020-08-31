// Copyright © 2020 Metabolist. All rights reserved.

import XCTest
import Combine
import CombineExpectations
import Mastodon
@testable import Metatext

class AddIdentityViewModelTests: XCTestCase {
    func testAddIdentity() throws {
        let identityDatabase = IdentityDatabase.fresh()
        let sut = AddIdentityViewModel(allIdentitiesService: .fresh(identityDatabase: identityDatabase))
        let addedIDRecorder = sut.addedIdentityID.record()

        sut.urlFieldText = "https://mastodon.social"
        sut.logInTapped()

        _ = try wait(for: addedIDRecorder.next(), timeout: 1)
    }

    func testAddIdentityWithoutScheme() throws {
        let identityDatabase = IdentityDatabase.fresh()
        let sut = AddIdentityViewModel(allIdentitiesService: .fresh(identityDatabase: identityDatabase))
        let addedIDRecorder = sut.addedIdentityID.record()

        sut.urlFieldText = "mastodon.social"
        sut.logInTapped()

        _ = try wait(for: addedIDRecorder.next(), timeout: 1)
    }

    func testInvalidURL() throws {
        let sut = AddIdentityViewModel(allIdentitiesService: .fresh())
        let recorder = sut.$alertItem.record()

        XCTAssertNil(try wait(for: recorder.next(), timeout: 1))

        sut.urlFieldText = "🐘.social"
        sut.logInTapped()

        let alertItem = try wait(for: recorder.next(), timeout: 1)

        XCTAssertEqual((alertItem?.error as? URLError)?.code, URLError.badURL)
    }

    func testDoesNotAlertCanceledLogin() throws {
        let environment = AppEnvironment(
            session: Session(configuration: .stubbing),
            webAuthSessionType: CanceledLoginMockWebAuthSession.self,
            keychainServiceType: MockKeychainService.self,
            userDefaults: MockUserDefaults(),
            inMemoryContent: true)
        let allIdentitiesService = AllIdentitiesService(
            identityDatabase: .fresh(),
            environment: environment)
        let sut = AddIdentityViewModel(allIdentitiesService: allIdentitiesService)
        let recorder = sut.$alertItem.record()

        XCTAssertNil(try wait(for: recorder.next(), timeout: 1))

        sut.urlFieldText = "https://mastodon.social"
        sut.logInTapped()

        try wait(for: recorder.next().inverted, timeout: 1)
    }
}
