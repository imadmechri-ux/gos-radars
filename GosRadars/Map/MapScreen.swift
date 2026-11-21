import CoreLocation
import SwiftUI
import MapLibre

/// Style de carte OpenStreetMap gratuit (OpenFreeMap). À remplacer si besoin.
let defaultMapStyleURL = URL(string: "https://tiles.openfreemap.org/styles/liberty")!

struct MapScreen: View {
    @EnvironmentObject private var location: LocationService

    var body: some View {
        ZStack(alignment: .topLeading) {
            MapView(styleURL: defaultMapStyleURL, location: location.location)
                .ignoresSafeArea()

            SpeedBadge(speedKmh: location.speedKmh)
                .accessibilityLabel("Vitesse actuelle")
                .padding()
        }
    }
}

struct SpeedBadge: View {
    let speedKmh: Double?

    var body: some View {
        VStack(spacing: 0) {
            Text(speedKmh.map { String(Int($0.rounded())) } ?? "--")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text("km/h")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Pont SwiftUI vers la vue MapLibre (UIKit).
struct MapView: UIViewRepresentable {
    let styleURL: URL
    let location: CLLocation?

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.zoomLevel = 15
        mapView.compassView.isHidden = false
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        // Le suivi est géré par MapLibre (userTrackingMode). Rien à mettre à jour ici pour le jalon 1.
    }
}
