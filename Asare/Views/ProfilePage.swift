import SwiftUI

struct ProfilePage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings

    @State private var email: String = "No Email"
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var showPasswordChangeAlert = false
    @State private var passwordChangeMessage = ""
    @State private var isPasswordSectionExpanded = false
    @State private var isEmailSectionExpanded = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Profile")
                    .font(settings.largeTitleFont)
                    .foregroundColor(.pink)
                    .padding()
                    .accessibilityAddTraits(.isHeader)

                
                ZStack {
                    Color(.systemGroupedBackground)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ScrollView {
                            VStack(spacing: 25) {
                                ProfileCard {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.pink)
                                        Text("Username: \(DatabaseManager.shared.getCurrentUser()?.username ?? "Unknown")")
                                            .font(settings.midTitleFont)
                                            .foregroundColor(.pink)
                                        Spacer()
                                    }
                                }
                                
                                //MARK: - Email Section
                                ProfileCard {
                                    VStack(spacing: 14) {
                                        Button(action: {
                                            withAnimation {
                                                isEmailSectionExpanded.toggle()
                                            }
                                        }) {
                                            HStack {
                                                Label("Update Email", systemImage: "envelope.fill")
                                                    .fontWeight(.semibold)
                                                    .font(settings.font)
                                                Spacer()
                                                Image(systemName: isEmailSectionExpanded ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.pink)
                                            }
                                        }
                                        
                                        if isEmailSectionExpanded {
                                            VStack(spacing: 16) {
                                                ProfileTextField(title: "Email", text: $email, icon: "envelope.fill")
                                                GradientButton(title: "Update Email", icon: "pencil", color: .pink) {
                                                    updateEmail()
                                                }
                                                .padding(.top, 4)
                                                .accessibilityAddTraits(.isButton)

                                            }
                                            .transition(.opacity.combined(with: .slide))
                                        }
                                    }
                                }
                                
                                //MARK: - Password Section
                                ProfileCard {
                                    VStack(spacing: 14) {
                                        Button(action: {
                                            withAnimation {
                                                isPasswordSectionExpanded.toggle()
                                            }
                                        }) {
                                            HStack {
                                                Label("Change Password", systemImage: "lock.fill")
                                                    .fontWeight(.semibold)
                                                    .font(settings.font)
                                                Spacer()
                                                Image(systemName: isPasswordSectionExpanded ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.pink)
                                            }
                                        }
                                        
                                        if isPasswordSectionExpanded {
                                            VStack(spacing: 12) {
                                                ProfileSecureField(title: "Current Password", text: $currentPassword)
                                                ProfileSecureField(title: "New Password", text: $newPassword)
                                                ProfileSecureField(title: "Confirm New Password", text: $confirmPassword)
                                                
                                                GradientButton(title: "Update Password", icon: "key.fill", color: .pink) {
                                                    changePassword()
                                                }
                                                .padding(.top, 8)
                                                .accessibilityAddTraits(.isButton)

                                            }
                                            .transition(.opacity.combined(with: .slide))
                                        }
                                    }
                                }
                                
                                //MARK: - Logout Button
                                GradientButton(title: "Logout", icon: "rectangle.portrait.and.arrow.forward", color: .red) {
                                    handleLogout()
                                }
                                .padding(.top)
                                .accessibilityAddTraits(.isButton)

                            }
                            .padding()
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemBackground))
                .onAppear(perform: loadUserProfile)
                .alert(isPresented: $showPasswordChangeAlert) {
                    Alert(title: Text("Update"), message: Text(passwordChangeMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    // MARK: - Functions

    private func loadUserProfile() {
        if let user = DatabaseManager.shared.getCurrentUser() {
            email = user.email
        }
    }

    private func updateEmail() {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            passwordChangeMessage = "No user logged in."
            showPasswordChangeAlert = true
            return
        }

        if currentUser.email == email {
            passwordChangeMessage = "Email is unchanged"
            showPasswordChangeAlert = true
            return
        }

        let success = DatabaseManager.shared.updateEmail(currentUsername: currentUser.username, newEmail: email)
        passwordChangeMessage = success ? "Email updated successfully." : "Failed to update email."
        showPasswordChangeAlert = true
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
                isPasswordSectionExpanded = false
            }
        } else {
            passwordChangeMessage = "Incorrect current password."
        }

        showPasswordChangeAlert = true
    }

    private func handleLogout() {
        DatabaseManager.shared.logoutUser()
        isAuthenticated = false

        settings.isDarkMode = false
        settings.fontSize = 16
        settings.useDyslexiaFont = false
        settings.measurementUnit = 0
    }
}

// MARK: - More Views

struct ProfileCard<Content: View>: View {
    @EnvironmentObject var settings: AppSettings

    var content: () -> Content

    var body: some View {
        VStack {
            content()
        }
        .padding()
        .background(settings.isDarkMode ? Color(uiColor: .secondarySystemBackground) :Color.white)
        .cornerRadius(20)
        .shadow(color: Color.pink.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ProfileTextField: View {
    @EnvironmentObject var settings: AppSettings

    var title: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
            TextField(title, text: $text)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .font(settings.font)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct ProfileSecureField: View {
    @EnvironmentObject var settings: AppSettings

    var title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .padding()
            .autocapitalization(.none)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .font(settings.font)
    }
}

struct GradientButton: View {
    @EnvironmentObject var settings: AppSettings

    var title: String
    var icon: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
                    .font(settings.font)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [color.opacity(0.9), color]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(radius: 5)
        }
    }
}
