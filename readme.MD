# A wrapper around CLLocationManager to handle location tracking and related permissions

## Latest values

`public func lastKnownLocation() -> CLLocation?`

`public func lastKnownHeading() -> CLHeading?`

## One Time requests
```
public func requestLocation(
    options: RequestHandlerOptions = .tenMeters,
    completion: LocationRequestCompletionHandler? = nil
)
```

## Constant Monitoring

`public func startMonitoringLocationPushes(completion: @escaping ((Data?, Error?) -> Void))`

`public func stopMonitoringLocationPushes()`

`public func startUpdatingHeading()`

`public func stopUpdatingHeading()`

## Authorization

`public func authorizationStatus() -> CLAuthorizationStatus`

// Requests whenInUseAuthorization

`public func requestWhenInUseAuthorization(completion: @escaping (AuthorizationError?) -> Void)`

// Requests whenInUseAuthorization if needed, then alwaysAuthorization

`public func requestAlwaysAuthorization(completion: @escaping (AuthorizationError?) -> Void)`

## Delegate methods

```
public protocol LocationTrackerDelegate: AnyObject {
    func locationTracker(didUpdateLocations locations: [CLLocation])
    func locationTracker(didFailWithError error: Error)
    func locationTracking(didChangeAuthorization status: CLAuthorizationStatus)
    func locationTracker(didUpdateHeading heading: CLHeading)
}
```