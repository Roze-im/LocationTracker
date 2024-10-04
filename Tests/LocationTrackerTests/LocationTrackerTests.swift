import XCTest

@testable import LocationTracker
@testable import LocationTrackerTesting
import CoreLocation

final class LocationTrackerTests: XCTestCase {
    enum SystemInteractionResponse {
        case accept(resultingIn: CLAuthorizationStatus)
        case deny(resultingIn: CLAuthorizationStatus)
    }

    func performTest(
        logger: @escaping Logger = { print("[\($0)] - \($1) : \($2)") },
        initialStatus: CLAuthorizationStatus = .notDetermined,
        expectedSystemPopupInteraction: Int,
        setup: ((MockCLLocationManager, MockLocationAuthorizationFlow) -> Void)? = nil,
        locationPrompt: @escaping (
            _ flow: LocationAuthorizationFlow,
            _ completion: @escaping (AuthorizationError?) -> Void
        ) -> Void,
        expectedRequestWhenInUseAuthorizationStatus: CLAuthorizationStatus,
        expectedRequestAlwaysAuthorizationStatus: CLAuthorizationStatus,
        resultsInError expectedError: AuthorizationError?,
        setupExpectations: ((MockCLLocationManager) -> [XCTestExpectation]) = { _ in return [] }
    ) {
        let mockManager = MockCLLocationManager()

        let mockDelegate = MockCLLocationManagerDelegate()
        mockManager.delegate = mockDelegate
        mockManager.authorizationStatus = initialStatus

        let authFlow = MockLocationAuthorizationFlow(logger: logger, locationManager: mockManager)
        setup?(mockManager, authFlow)

        // Forward authorizationStatus updates to authFlow
        let authChangeExpectation = self.expectation(description: "authorizationStatus changed")
        if expectedSystemPopupInteraction == 0 {
            authChangeExpectation.isInverted = true
        } else {
            authChangeExpectation.expectedFulfillmentCount = expectedSystemPopupInteraction
        }
        mockDelegate.onLocationManagerDidChangeAuthorization = { auth in
            authChangeExpectation.fulfill()
            authFlow.onLocationAuthorizationUpdated?()
        }


        mockManager.expectedRequestWhenInUseAuthorizationStatus = expectedRequestWhenInUseAuthorizationStatus
        mockManager.expectedRequestAlwaysAuthorizationStatus = expectedRequestAlwaysAuthorizationStatus

        let locationPrompted = self.expectation(description: "prompting")
        locationPrompt(authFlow) { error in
            XCTAssertEqual(error, expectedError)
            locationPrompted.fulfill()
        }

        withExtendedLifetime(mockDelegate) {
            waitForExpectations(timeout: 1)
        }
    }
}

// MARK: - From notDetermined state
extension LocationTrackerTests {
    // WhenInUseAccess
    func testGrantWhenInUseAccessFromNotDetermined() throws {
        performTest(
            expectedSystemPopupInteraction: 1,
            locationPrompt: { flow, completion in
                flow.promptWhenInUseLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .authorizedWhenInUse,
            expectedRequestAlwaysAuthorizationStatus: .notDetermined,
            resultsInError: nil
        )
    }

    func testDenyWhenInUseAccessFromNotDetermined() throws {
        performTest(
            expectedSystemPopupInteraction: 1,
            locationPrompt: { flow, completion in
                flow.promptWhenInUseLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .denied,
            expectedRequestAlwaysAuthorizationStatus: .notDetermined,
            resultsInError: .locationDenied
        )
    }

    // authorizedAlways
    func testGrantAlwaysAccessFromNotDetermined() throws {
        performTest(
            expectedSystemPopupInteraction: 2,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .authorizedWhenInUse,
            expectedRequestAlwaysAuthorizationStatus: .authorizedAlways,
            resultsInError: nil
        )
    }

    func testDenyAlwaysAccessFromNotDetermined() throws {
        performTest(
            expectedSystemPopupInteraction: 2,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .authorizedWhenInUse,
            expectedRequestAlwaysAuthorizationStatus: .authorizedWhenInUse,
            resultsInError: .backgroundLocationDenied
        )
    }
    func testDenyInUseAccessWhenPromptingAlwaysAccessFromNotDetermined() throws {
        performTest(
            expectedSystemPopupInteraction: 1,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .denied,
            expectedRequestAlwaysAuthorizationStatus: .notDetermined,
            resultsInError: .locationDenied
        )
    }
}

// MARK: - From whenInUse state
extension LocationTrackerTests {
    // authorizedAlways
    func testGrantAlwaysAccessFromWhenInUse() throws {
        performTest(
            initialStatus: .authorizedWhenInUse,
            expectedSystemPopupInteraction: 1,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .restricted /* not relevant */,
            expectedRequestAlwaysAuthorizationStatus: .authorizedAlways,
            resultsInError: nil
        )
    }

    func testDenyAlwaysAccessFromWhenInUse() throws {
        performTest(
            initialStatus: .authorizedWhenInUse,
            expectedSystemPopupInteraction: 1,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .restricted /* not relevant */,
            expectedRequestAlwaysAuthorizationStatus: .authorizedWhenInUse,
            resultsInError: .backgroundLocationDenied
        )
    }
}

// MARK: - From whenInUse denied state
extension LocationTrackerTests {
    // authorizedAlways
    func testRequestWhenInUseFromWhenInUseDenied() throws {
        performTest(
            initialStatus: .denied,
            expectedSystemPopupInteraction: 0,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .restricted /* not relevant */,
            expectedRequestAlwaysAuthorizationStatus: .authorizedWhenInUse,
            resultsInError: .locationDenied
        )
    }
    func testRequestAlwaysAccessFromWhenInUseDenied() throws {
        performTest(
            initialStatus: .denied,
            expectedSystemPopupInteraction: 0,
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .restricted /* not relevant */,
            expectedRequestAlwaysAuthorizationStatus: .authorizedWhenInUse,
            resultsInError: .locationDenied
        )
    }
}

// MARK: - From background denied state
extension LocationTrackerTests {
    // authorizedAlways
    func testRequestAlwaysAccessFromAlwaysAccessDenied() throws {
        performTest(
            initialStatus: .authorizedWhenInUse,
            expectedSystemPopupInteraction: 0,
            setup: { _, flow in flow.mockHasPromptedBackgroundLocation() },
            locationPrompt: { flow, completion in
                flow.promptBackgroundLocationAccess(completion: completion)
            },
            expectedRequestWhenInUseAuthorizationStatus: .restricted /* not relevant */,
            expectedRequestAlwaysAuthorizationStatus: .authorizedWhenInUse,
            resultsInError: .backgroundLocationDenied
        )
    }
}
