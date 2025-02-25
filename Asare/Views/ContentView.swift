import SwiftUI

struct ContentView: View {
    @StateObject var settings = AppSettings() //create AppSettings as a StateObject
    @State private var isAuthenticated: Bool = DatabaseManager.shared.isUserAuthenticated() //Get auth status from SQLite
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
                TabView {
                    NavigationStack {
                        HomePage()
                            .environmentObject(settings)
                            .overlay(
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
                                loadUserSettings()

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

                    NavigationStack {
                        RecipesView()
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
                    
//                    // View All Square Recipes Tab
//                    NavigationStack {SquareRecipe()
//                            .environmentObject(settings)
//                    }
//                    .tabItem {
//                        Image(systemName: "book.fill")
//                        Text("Square Recipes")
//                    }
//                    // View All Recipes Tab
//                    NavigationStack {
//                        ViewRecipesPage()
//                            .environmentObject(settings)
//                    }
//                    .tabItem {
//                        Image(systemName: "book.fill")
//                        Text("List Recipes")
//                    }
                   
                }.accentColor(.pink)
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
                .onAppear {
                    loadUserSettings() //Load settings when ContentView appears
                }
            } else {
                //Show LoginPage if not authenticated
                LoginPage(isAuthenticated: $isAuthenticated)
                    .environmentObject(settings)
                    .onDisappear {
                        //Ensure the `isAuthenticated` is reset to false when leaving the login screen
                        isAuthenticated = DatabaseManager.shared.isUserAuthenticated()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
