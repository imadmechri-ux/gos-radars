import SwiftUI

@main
struct GosRadarsApp: App {
    @StateObject private var location = LocationService()

    var body: some Scene {
        WindowGroup {
            MapScreen()
                .environmentObject(location)
                .onAppear { location.start() }
        }
    }
}
