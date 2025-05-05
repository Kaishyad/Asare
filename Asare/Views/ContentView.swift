import SwiftUI

struct ContentView: View {
    @StateObject var settings = AppSettings()
    @State private var isAuthenticated: Bool = DatabaseManager.shared.isUserAuthenticated()
    @State private var showBanner: Bool = false
    @State private var didInitialLoad = false

    private let settingsManager = UserSettingsManager.shared

    func loadUserSettings() { //load in some app settings for the user to use at start
        guard !didInitialLoad else { return }
        didInitialLoad = true
        
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
                    //Code Adapted from Indently, 2021 for the bottom nav bar
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
                    }                                        .accessibilityAddTraits(.isButton)


                    // Create Recipe Tab
                    NavigationStack {
                        CreateRecipePage()
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create")
                    }                                        .accessibilityAddTraits(.isButton)

                    // Settings Tab
                    NavigationStack {
                        SettingsPage()
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }                                        .accessibilityAddTraits(.isButton)


                    // Profile Tab
                    NavigationStack {
                        ProfilePage(isAuthenticated: $isAuthenticated)
                            .environmentObject(settings)
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }                                        .accessibilityAddTraits(.isButton)


                    //End of Adaption

                   
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
                        isAuthenticated = DatabaseManager.shared.isUserAuthenticated()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
