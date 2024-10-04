//
//  LocationTracker+AuthorizationStatus.swift
//  
//
//  Created by Benjamin Garrigues on 28/02/2024.
//

import Foundation
import CoreLocation

extension LocationTracker {

    public func authorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }

    /// Requests whenInUseAuthorization
    public func requestWhenInUseAuthorization(completion: @escaping (AuthorizationError?) -> Void) {
        locationAuthorizationFlow.promptWhenInUseLocationAccess(completion: completion)
    }
    
    /// Requests whenInUseAuthorization if needed, then alwaysAuthorization
    public func requestAlwaysAuthorization(completion: @escaping (AuthorizationError?) -> Void) {
        locationAuthorizationFlow.promptBackgroundLocationAccess(completion: completion)
    }
}
