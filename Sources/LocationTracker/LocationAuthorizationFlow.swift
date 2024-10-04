//
//  LocationAuthorizationFlow.swift
//
//
//  Created by Thibaud David on 01/03/2024.
//

import Foundation

open class LocationAuthorizationFlow {
    let locationManager: any LocationManager
    let logger: Logger

    public init(logger: @escaping Logger, locationManager: any LocationManager) {
        self.logger = logger
        self.locationManager = locationManager
    }

    open var hasPromptedBackgroundLocationAccessKey = "im.roze.locationtracker.promptedBackgroundLocation"
    public var hasPromptedBackgroundLocationAccess: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasPromptedBackgroundLocationAccessKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: hasPromptedBackgroundLocationAccessKey)
        }
    }

    var onLocationAuthorizationUpdated: (() -> Void)?

    func promptWhenInUseLocationAccess(completion: @escaping (AuthorizationError?) -> Void) {
        logger(self, .debug, "[InUsePrompt] promptWhenInUseLocationAccess")
        switch locationManager.authorizationStatus {
        case .notDetermined:
            logger(self, .debug, "[InUsePrompt] … notDetermined, requestWhenInUseAuthorization")
            onLocationAuthorizationUpdated = { [weak self] in
                defer { self?.onLocationAuthorizationUpdated = nil }
                self?.promptWhenInUseLocationAccess(completion: completion)
            }
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            logger(self, .debug, "[InUsePrompt] … authorized")
            completion(nil)

        case .denied, .restricted:
            logger(self, .debug, "[InUsePrompt] … denied or restricted")
            completion(.locationDenied)

        @unknown default:
            logger(self, .debug, "[InUsePrompt] … unknown value")
            completion(.unexpected(
                NSError(
                    domain: "BackgroundLocationAuthorizationFlow.promptWhenInUseLocationAccess",
                    code: 1,
                    userInfo: [NSLocalizedFailureErrorKey: "Unknown authorizationStatus \(locationManager.authorizationStatus)"]
                )
            ))
        }
    }

    func promptBackgroundLocationAccess(completion: @escaping (AuthorizationError?) -> Void) {
        logger(self, .debug, "[AlwaysPrompt] promptBackgroundLocationAccess")
        switch locationManager.authorizationStatus {
        case .notDetermined:
            logger(self, .debug, "[AlwaysPrompt] … not determined, promptWhenInUseLocationAccess")
            promptWhenInUseLocationAccess { [weak self] _ in
                self?.promptBackgroundLocationAccess(completion: completion)
            }

        case .authorizedWhenInUse where !hasPromptedBackgroundLocationAccess:
            logger(self, .debug, "[AlwaysPrompt] … authorizedWhenInUse, requestAlwaysAuthorization")
            onLocationAuthorizationUpdated = { [weak self] in
                defer { self?.onLocationAuthorizationUpdated = nil }
                self?.promptBackgroundLocationAccess(completion: completion)
            }
            hasPromptedBackgroundLocationAccess = true
            locationManager.requestAlwaysAuthorization()

        case .authorizedWhenInUse:
            logger(self, .debug, "[AlwaysPrompt] … authorizedWhenInUse, whereas background access already prompted")
            // We are still .authorizedWhenInUse, even though background access has already being prompted
            completion(.backgroundLocationDenied)

        case .authorizedAlways:
            logger(self, .debug, "[AlwaysPrompt] … authorized")
            completion(nil)

        case .denied, .restricted:
            logger(self, .debug, "[AlwaysPrompt] … denied or restricted")
            completion(.locationDenied)

        @unknown default:
            logger(self, .error, "[AlwaysPrompt] … unknown value")
            completion(.unexpected(
                NSError(
                    domain: "BackgroundLocationAuthorizationFlow.promptBackgroundLocationAccess",
                    code: 1,
                    userInfo: [NSLocalizedFailureErrorKey: "Unknown authorizationStatus \(locationManager.authorizationStatus)"]
                )
            ))
        }
    }
}

public enum AuthorizationError: Error {
    case locationDenied
    case backgroundLocationDenied
    case unexpected(Error)
}
