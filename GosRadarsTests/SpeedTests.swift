import CoreLocation
import XCTest
@testable import GosRadars

final class SpeedTests: XCTestCase {
    func testSpeedIsNilWithoutLocation() {
        let service = LocationService()
        XCTAssertNil(service.speedKmh)
    }

    func testNegativeSpeedIsIgnored() {
        let service = LocationService()
        service.location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.85, longitude: 2.35),
            altitude: 0, horizontalAccuracy: 5, verticalAccuracy: -1,
            course: -1, speed: -1, timestamp: Date())
        XCTAssertNil(service.speedKmh)
    }

    func testSpeedConvertsMetersPerSecondToKmh() {
        let service = LocationService()
        service.location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.85, longitude: 2.35),
            altitude: 0, horizontalAccuracy: 5, verticalAccuracy: -1,
            course: 90, speed: 10, timestamp: Date())
        XCTAssertEqual(service.speedKmh ?? 0, 36, accuracy: 0.001)
    }
}
