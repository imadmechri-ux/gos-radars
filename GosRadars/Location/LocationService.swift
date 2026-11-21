import Combine
import CoreLocation

/// Suit la position, la vitesse et le cap de l'utilisateur.
final class LocationService: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published private(set) var authorization: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private var started = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = kCLDistanceFilterNone
        manager.activityType = .automotiveNavigation
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
        authorization = manager.authorizationStatus
    }

    func start() {
        guard !started else { return }
        started = true
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    /// Vitesse en km/h, ou nil si le GPS ne la fournit pas encore.
    var speedKmh: Double? {
        guard let speed = location?.speed, speed >= 0 else { return nil }
        return speed * 3.6
    }

    /// Cap en degrés (0 = nord), ou nil si indisponible.
    var courseDegrees: Double? {
        guard let course = location?.course, course >= 0 else { return nil }
        return course
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        location = last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        switch authorization {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Erreurs transitoires (signal perdu) : on garde la dernière position connue.
    }
}
