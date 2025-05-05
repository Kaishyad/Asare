import SwiftUI

@main
struct AsareApp: App {
    // Initialize the shared DatabaseManager instance
    init() {
        _ = DatabaseManager.shared
    }
    
    // Create an instance of AppSettings to be shared across the app
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            // Inject AppSettings into the environment so that it can be accessed by any view
            ContentView()
                .environmentObject(appSettings)
        }
    }
}
