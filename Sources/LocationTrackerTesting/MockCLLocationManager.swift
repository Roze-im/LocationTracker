//
//  MockCLLocationManager.swift
//
//
//  Created by Thibaud David on 04/03/2024.
//

import Foundation
import LocationTracker
import CoreLocation

/// A mock implementing LocationManager.
/// DON'T use CLLocationManager forwarding through delegates, as it's a dummy instance
public class MockCLLocationManager: LocationManager {

    public weak var delegate: CLLocationManagerDelegate?

    public var location: CLLocation?
    
    public var heading: CLHeading?

    public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    public var desiredAccuracy: CLLocationAccuracy = 100

    private(set) var dummyManager = CLLocationManager()

    public init() {}

    public func requestLocation() {
        assertionFailure("requestLocation: MOCK NOT IMPLEMENTED")
    }
    
    public func startUpdatingLocation() {
        assertionFailure("startUpdatingLocation: MOCK NOT IMPLEMENTED")
    }
    
    public func stopUpdatingLocation() {
        assertionFailure("stopUpdatingLocation: MOCK NOT IMPLEMENTED")
    }
    
    public func startUpdatingHeading() {
        assertionFailure("startUpdatingHeading: MOCK NOT IMPLEMENTED")
    }
    
    public func stopUpdatingHeading() {
        assertionFailure("stopUpdatingHeading: MOCK NOT IMPLEMENTED")
    }
    
    public func setMockLocationToken(_ hexToken: String?, error: Error?) {
        let tokenData = hexToken?.toHextData()
        expectedStartMonitoringLocationPushesResult = (tokenData, error)
    }
    public var expectedStartMonitoringLocationPushesResult: (Data?, Error?)
    public var onStartMonitoringLocationPushes: (() -> Void)?
    public func startMonitoringLocationPushes(completion: ((Data?, Error?) -> Void)?) {
        completion?(expectedStartMonitoringLocationPushesResult.0, expectedStartMonitoringLocationPushesResult.1)
        onStartMonitoringLocationPushes?()
    }
    
    public var onStopMonitoringLocationPushes: (() -> Void)?
    public func stopMonitoringLocationPushes() {
        onStopMonitoringLocationPushes?()
    }
    
    public var expectedRequestWhenInUseAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    public func requestWhenInUseAuthorization() {
        authorizationStatus = expectedRequestWhenInUseAuthorizationStatus
        print("requestWhenInUseAuthorization, new status: \(authorizationStatus)")
        delegate?.locationManagerDidChangeAuthorization?(dummyManager)
    }
    
    public var expectedRequestAlwaysAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    public func requestAlwaysAuthorization() {
        authorizationStatus = expectedRequestAlwaysAuthorizationStatus
        print("requestAlwaysAuthorization, new status: \(authorizationStatus)")
        delegate?.locationManagerDidChangeAuthorization?(dummyManager)
    }

    public static func == (lhs: MockCLLocationManager, rhs: MockCLLocationManager) -> Bool {
        return lhs.dummyManager === rhs.dummyManager
    }
}
