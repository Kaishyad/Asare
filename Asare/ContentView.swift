import SwiftUI

struct ContentView: View {
    @StateObject var settings = AppSettings()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Recipe Manager 🍲")
                    .font(settings.font) // Uses the global font
                    .padding()

                NavigationLink(destination: ViewRecipesPage().environmentObject(settings)) {
                    Text("📖 View All Recipes")
                        .font(settings.font) // Apply font to buttons
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: CreateRecipePage().environmentObject(settings)) {
                    Text("➕ Create Recipe")
                        .font(settings.font)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: SettingsPage().environmentObject(settings)) {
                    Text("⚙️ Settings")
                        .font(settings.font)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    ContentView()
}
