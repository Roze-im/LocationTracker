//
//  MockLocationAuthorizationFlow.swift
//
//
//  Created by Thibaud David on 04/03/2024.
//

import Foundation
import LocationTracker

public class MockLocationAuthorizationFlow: LocationAuthorizationFlow {
    public override init(logger: @escaping Logger, locationManager: any LocationManager) {
        super.init(logger: logger, locationManager: locationManager)

        // Set a custom key for unit tests to be isolated
        hasPromptedBackgroundLocationAccessKey = "\(hasPromptedBackgroundLocationAccessKey)_\(UUID().uuidString)"
    }

    public func mockHasPromptedBackgroundLocation() {
        hasPromptedBackgroundLocationAccess = true
    }
}
