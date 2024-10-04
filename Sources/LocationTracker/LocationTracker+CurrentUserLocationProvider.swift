//
//  File.swift
//  
//
//  Created by Benjamin Garrigues on 16/05/2024.
//

import Foundation
import CoreLocation

extension LocationTracker {
    public func requestCurrentUserLocation(accuracy: CLLocationAccuracy, completion: @escaping (CLLocation?) -> Void) {
        guard authorizationStatus() == .authorizedAlways else {
            completion(nil)
            return
        }
        requestLocation(options: .init(stopAtAccuracy: accuracy)) { [weak self] res in
            guard let self else { return }
            switch res {
            case .failure(let error):
                logger(self, .error, "🚨 request Location error : \(error)")
                completion(nil)

            case .success(let locations):
                completion(locations.last)
            }
        }
    }
    
    public func currentUserLastKnownLocation() -> CLLocation? {
        guard let loc = lastKnownLocation(), loc.coordinate != .zero else {
            return nil
        }
        return loc
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    static let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
