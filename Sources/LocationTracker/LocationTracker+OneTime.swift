//
//  File.swift
//  
//
//  Created by Benjamin Garrigues on 28/02/2024.
//

import Foundation
import CoreLocation

extension LocationTracker {
    public typealias LocationRequestCompletionHandler = (Result<[CLLocation], Error>) -> Void
    public struct RequestHandlerOptions {
        // handler will only be called if the location meets the desired accuracy
        let stopAtAccuracy: CLLocationAccuracy // the higher the worst quality.

        public init(stopAtAccuracy: CLLocationAccuracy) {
            self.stopAtAccuracy = stopAtAccuracy
        }

        public static let tenMeters = RequestHandlerOptions(
            stopAtAccuracy: kCLLocationAccuracyNearestTenMeters
        )
        public static let hundredMeters = RequestHandlerOptions(
            stopAtAccuracy: kCLLocationAccuracyHundredMeters
        )
    }

    public struct LocationRequest {
        let handler: LocationRequestCompletionHandler
        var options: RequestHandlerOptions
        var lastReceivedLocations: [CLLocation]
        var createdAt: Date
        public init(handler: @escaping LocationRequestCompletionHandler, options: RequestHandlerOptions) {
            self.handler = handler
            self.options = options
            self.createdAt = Date()
            lastReceivedLocations = []
        }
    }

    // MARK: - One-time requests
    // MARK: request creation
    public func requestLocation(options: RequestHandlerOptions = .tenMeters,
                                completion: LocationRequestCompletionHandler? = nil) {
        #warning("TODO: test the behavior regarding error callbacks")
        // is the error CLLocationManager delegate call called because of the previous request ?
        // could there be a race where the new request would be considered in error ?

        locationManager.desiredAccuracy = options.stopAtAccuracy

        // Due to a limitation of CLLocationManager, calling requestLocation() will
        // immediately cancel outstanding requests.
        var needsSpawnRequest = true
        locationRequests {
            needsSpawnRequest = $0.isEmpty && completion != nil

            if let completion {
                $0.append(.init(handler: completion, options: options))
            }
        }

        if needsSpawnRequest {
            locationManager.requestLocation()
        }
    }

    // MARK: request completion
    /// Poping all request that meet a certain condition.
    /// Filter can update the request if needed.
    /// Note : for now, only a single request can be processed at a time (CLLocationManager limitation)
    func popAllRequests(_ filter: (inout LocationRequest) -> Bool) -> [LocationRequest] {
        var res = [LocationRequest]()
        // don't call the handlers directly in the synchronized access thread :
        // if the handler makes a reentrant call to requestHandlers it's a deadlock.
        locationRequests {
            var poppedRequests = [LocationRequest]()
            var keptRequests = [LocationRequest]()
            for h in $0 {
                var updatedH = h
                // those that don't pass the pop filter will be kept.
                if !filter(&updatedH) {
                    keptRequests.append(updatedH)
                } else {
                    poppedRequests.append(updatedH)
                }
            }
            $0 = keptRequests
            res = poppedRequests
        }
        return res
    }

}
