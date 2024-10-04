//
//  MockCLLocationManagerDelegate.swift
//
//
//  Created by Thibaud David on 04/03/2024.
//

import Foundation
import CoreLocation

public class MockCLLocationManagerDelegate: NSObject, CLLocationManagerDelegate {

    var onLocationManagerDidChangeAuthorization: ((CLAuthorizationStatus) -> Void)?
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onLocationManagerDidChangeAuthorization?(manager.authorizationStatus)
    }
}
