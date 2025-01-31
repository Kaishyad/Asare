import SwiftUI

struct ProfilePage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings

    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? "No Username"
    @State private var email: String = UserDefaults.standard.string(forKey: "email") ?? "No Email"
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            Text("Username: \(username)")
                .font(settings.font)
            
            Text("Email: \(email)")
                .font(settings.font)

            Button(action: handleLogout) {
                Text("Logout")
                    .font(settings.font)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
    }

    private func handleLogout() {
        // Clear authentication state and return to LoginPage
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        isAuthenticated = false
    }
}

#Preview {
    ProfilePage(isAuthenticated: .constant(true))
}
