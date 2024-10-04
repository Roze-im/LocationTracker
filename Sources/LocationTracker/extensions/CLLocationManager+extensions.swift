//
//  File.swift
//  
//
//  Created by Thibaud David on 04/03/2024.
//

import Foundation
import CoreLocation

extension CLLocationManager: LocationManager {
    #if targetEnvironment(macCatalyst)
    public func startMonitoringLocationPushes(completion: ((Data?, Error?) -> Void)?) {
        assertionFailure("Location Push Service extensions are not available when building for Mac Catalyst")
    }
    public func stopMonitoringLocationPushes() {
        assertionFailure("Location Push Service extensions are not available when building for Mac Catalyst")
    }
    #endif
}
