//
//  LocationManager.swift
//
//
//  Created by Thibaud David on 04/03/2024.
//

import Foundation
import CoreLocation

public protocol LocationManager: AnyObject, Equatable {
    var delegate: CLLocationManagerDelegate? { get set }
    var location: CLLocation? { get }
    var heading: CLHeading? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var desiredAccuracy: CLLocationAccuracy { get set }

    func requestLocation()

    func startUpdatingLocation()
    func stopUpdatingLocation()

    func startUpdatingHeading()
    func stopUpdatingHeading()

    func startMonitoringLocationPushes(completion: ((Data?, Error?) -> Void)?)
    func stopMonitoringLocationPushes()

    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
}
