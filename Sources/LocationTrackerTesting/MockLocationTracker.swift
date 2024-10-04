//
//  MockLocationTracker.swift
//
//
//  Created by Benjamin Garrigues on 28/02/2024.
//

import Foundation
import LocationTracker
import CoreLocation

public class MockLocationTracker: LocationTracker {

    public let mockLocationManager: MockCLLocationManager

    public init(logger: @escaping Logger, locationManager: MockCLLocationManager) {
        self.mockLocationManager = locationManager
        super.init(
            logger: logger,
            locationManager: locationManager
        )
    }
    
    public override class func initializeAuthorizationFlow(
        logger: @escaping Logger, locationManager: any LocationManager
    ) -> LocationAuthorizationFlow {
        return MockLocationAuthorizationFlow(logger: logger, locationManager: locationManager)
    }

    public override func isCurrentManager(_ manager: CLLocationManager) -> Bool {
        return manager == mockLocationManager.dummyManager
    }
}
