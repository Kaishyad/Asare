import SwiftUI

struct ContentView: View {
    @StateObject var settings = AppSettings() // Create AppSettings as a StateObject
    @State private var isAuthenticated: Bool = DatabaseManager.shared.isUserAuthenticated() // Get auth status from SQLite
    @State private var showBanner: Bool = false

    private let settingsManager = UserSettingsManager.shared

    func loadUserSettings() {
        if let user = DatabaseManager.shared.getCurrentUser(),
           let userSettings = settingsManager.getUserSettings(username: user.username) {
            settings.isDarkMode = userSettings.darkMode
            settings.fontSize = userSettings.fontSize
            settings.useDyslexiaFont = userSettings.useDyslexiaFont
            settings.measurementUnit = userSettings.measurementUnit
        }
    }

    var body: some View {
        NavigationStack {
            if isAuthenticated {
                // Show the TabView if authenticated
                TabView {
                    // Home Page Tab
                    NavigationStack {
                        HomePage()
                            .environmentObject(settings)
                            .overlay(
                                // Show banner if successful sign-up
                                Group {
                                    if showBanner {
                                        HStack {
                                            Text("Sign Up Successful!")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.green)
                                                .cornerRadius(10)
                                        }
                                        .padding()
                                        .transition(.move(edge: .top))
                                    }
                                }
                            )
                            .onAppear {
                                loadUserSettings() // Load settings when HomePage appears

                                // Hide the banner after 3 seconds
                                if showBanner {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showBanner = false
                                        }
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                    // View All Recipes Tab
                    NavigationStack {
                        ViewRecipesPage()
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Recipes")
                    }

                    // Create Recipe Tab
                    NavigationStack {
                        CreateRecipePage()
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }

                    // Settings Tab
                    NavigationStack {
                        SettingsPage()
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }

                    // Profile Tab
                    NavigationStack {
                        ProfilePage(isAuthenticated: $isAuthenticated)
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }.accentColor(.pink)
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
                .onAppear {
                    loadUserSettings() // Load settings when ContentView appears
                }
            } else {
                // Show LoginPage if not authenticated
                LoginPage(isAuthenticated: $isAuthenticated)
                    .environmentObject(settings)
            }
        }
    }
}

#Preview {
    ContentView()
}
