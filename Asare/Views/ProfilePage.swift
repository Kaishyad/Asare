import SwiftUI

struct ProfilePage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings

    @State private var username: String = "No Username"
    @State private var email: String = "No Email"
    
    // State variables for password change
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPasswordChangeAlert = false
    @State private var passwordChangeMessage = ""
    @State private var isPasswordSectionExpanded = false  // Tracks if password section is shown

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

            Divider().padding(.vertical, 10)

            // Toggle button for Change Password Section
            Button(action: {
                withAnimation {
                    isPasswordSectionExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Change Password")
                        .font(settings.font)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isPasswordSectionExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.top)

            // Collapsible Password Section
            if isPasswordSectionExpanded {
                VStack {
                    SecureField("Current Password", text: $currentPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: changePassword) {
                        Text("Update Password")
                            .font(settings.font)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .transition(.slide) // Smooth slide transition
            }

            Divider().padding(.vertical, 10)

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
        .onAppear {
            loadUserProfile()
        }
        .alert(isPresented: $showPasswordChangeAlert) {
            Alert(title: Text("Password Change"), message: Text(passwordChangeMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func loadUserProfile() {
        if let user = DatabaseManager.shared.getCurrentUser() {
            username = user.username
            email = user.email
        } else {
            username = "No User Logged In"
            email = "No Email"
        }
    }

    private func changePassword() {
        guard let user = DatabaseManager.shared.getCurrentUser() else {
            passwordChangeMessage = "No user logged in."
            showPasswordChangeAlert = true
            return
        }

        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            passwordChangeMessage = "All fields are required."
            showPasswordChangeAlert = true
            return
        }

        guard newPassword == confirmPassword else {
            passwordChangeMessage = "New passwords do not match."
            showPasswordChangeAlert = true
            return
        }

        if DatabaseManager.shared.validateUser(username: user.username, password: currentPassword) {
            DatabaseManager.shared.updatePassword(username: user.username, newPassword: newPassword)
            passwordChangeMessage = "Password successfully changed."
            withAnimation {
                isPasswordSectionExpanded = false // Collapse section after success
            }
        } else {
            passwordChangeMessage = "Incorrect current password."
        }

        showPasswordChangeAlert = true
    }

    private func handleLogout() {
        DatabaseManager.shared.logoutUser()
        isAuthenticated = false

        // Reset settings to default values when logging out
        settings.isDarkMode = false
        settings.fontSize = 16
        settings.useDyslexiaFont = false
        settings.measurementUnit = "Metric"
    }
}

#Preview {
    ProfilePage(isAuthenticated: .constant(true))
}
