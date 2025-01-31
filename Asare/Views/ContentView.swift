import SwiftUI

struct ContentView: View {
    @StateObject var settings = AppSettings() // Create AppSettings as a StateObject
    @State private var isAuthenticated: Bool = UserDefaults.standard.bool(forKey: "isAuthenticated")
    @State private var showBanner: Bool = false

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
                }
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
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
