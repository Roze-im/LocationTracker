// The Swift Programming Language
// https://docs.swift.org/swift-book
import CoreLocation


public protocol LocationTrackerDelegate: AnyObject {
    func locationTracker(didUpdateLocations locations: [CLLocation])
    func locationTracker(didFailWithError error: Error)
    func locationTracking(didChangeAuthorization status: CLAuthorizationStatus)
    func locationTracker(didUpdateHeading heading: CLHeading)
}

open class LocationTracker: NSObject, CLLocationManagerDelegate {

    enum LocationTrackerError: Error {
        case requestExpired
        case newRequestLaunched // whenever another request is scheduled, it kills the previous ones (CLLocationManager limitation)
        case continuousMonitoring // whenever entering Monitoring mode, CLLocationManager kills the one-time requests.
    }

    // MARK: - Dependencies
    let logger: Logger
    var locationManager: any LocationManager
    public weak var delegate: LocationTrackerDelegate?

    let locationAuthorizationFlow: LocationAuthorizationFlow
    open class func initializeAuthorizationFlow(
        logger: @escaping Logger, locationManager: any LocationManager
    ) -> LocationAuthorizationFlow {
        return LocationAuthorizationFlow(logger: logger, locationManager: locationManager)
    }

    // MARK: - State
    var locationRequests = Synchronized<[LocationRequest]>(
        [],
        accessQueueLabel: "synchronized.locationtrack.requesthandler",
        accessQueueQos: .userInitiated, // Synchronized<> makes blocking access, so better not put the QoS too low in case it's in the main thread path.
        targetQueue: DispatchQueue.global(qos: .userInitiated)
    )

    // MARK: - PUBLIC API
    public init(
        logger: @escaping Logger,
        locationManager: any LocationManager = CLLocationManager()
    ) {
        self.logger = logger
        self.locationManager = locationManager
        self.locationAuthorizationFlow = type(of: self).initializeAuthorizationFlow(
            logger: logger, locationManager: locationManager
        )
        super.init()
        self.locationManager.delegate = self
    }

    // MARK: Convenience accessor
    public func lastKnownLocation() -> CLLocation? {
        return locationManager.location
    }
    public func lastKnownHeading() -> CLHeading? {
        return locationManager.heading
    }

    // MARK: Constant Monitoring
    func startMonitoringLocation(monitorHeadingToo: Bool = true) {
        popAllRequests { _ in return true }.forEach {
            $0.handler(.failure(LocationTrackerError.continuousMonitoring))
        }
        locationManager.startUpdatingLocation()
        if monitorHeadingToo {
            locationManager.startUpdatingHeading()
        }
    }

    func stopMonitoringLocationAndHeading() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    // MARK: Location Push Notification
    public func startMonitoringLocationPushes(completion: @escaping ((Data?, Error?) -> Void)) {
        logger(self, .debug, "startMonitoringLocationPushes")
        locationManager.startMonitoringLocationPushes(completion: completion)
    }

    public func stopMonitoringLocationPushes() {
        locationManager.stopMonitoringLocationPushes()
    }

    // For tests
    open func isCurrentManager(_ manager: CLLocationManager) -> Bool {
        return manager === locationManager
    }

    public func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    public func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
}

extension CLLocation {
    var syntheticAccuracy: CLLocationAccuracy {
        return max(horizontalAccuracy, verticalAccuracy)
    }
}
