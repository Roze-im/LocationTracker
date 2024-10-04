//
//  LocationTracker+CLLocationManagerDelegate.swift
//
//
//  Created by Benjamin Garrigues on 28/02/2024.
//

import Foundation
import CoreLocation

extension LocationTracker {

    // MARK: - CLLocationManagerDelegate methods
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // location manager doesn't support concurrency
        popAllRequests{ _ in return true }.forEach { $0.handler(.success(locations)) }
        delegate?.locationTracker(didUpdateLocations: locations)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        popAllRequests{ _ in return true }.forEach { $0.handler(.failure(error)) }
        delegate?.locationTracker(didFailWithError: error)
    }


    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isCurrentManager(manager) else { return }
        locationAuthorizationFlow.onLocationAuthorizationUpdated?()
        delegate?.locationTracking(didChangeAuthorization: authorizationStatus())
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.locationTracker(didUpdateHeading: newHeading)
    }
}
