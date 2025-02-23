//
//  AsareApp.swift
//  Asare
//
//  Created by Kaishya Desai on 31/01/2025.
//

import SwiftUI

@main
struct AsareApp: App {
    // Initialize your SQLite DatabaseManager on launch.
    init() {
        _ = DatabaseManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Provide your AppSettings or any other environment objects here if needed
        }
    }
}
