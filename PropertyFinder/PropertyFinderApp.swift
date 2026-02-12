import SwiftUI

@main
struct PropertyFinderApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: coordinator, container: container)
        }
    }
}
