import SwiftUI

struct SignUpPage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var showSuccessBanner: Bool = false

    var body: some View {
        NavigationStack {
            VStack {

                Text("Asare")
                    .font(.system(size: 60, weight: .bold, design: .serif))
                    .kerning(2)
                    .foregroundStyle(
                        LinearGradient(colors: [Color.pink,Color.pink, Color.purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 10)
                    .padding(.top, 30)


                
                VStack(spacing: 15) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .accessibilityLabel("Create Account Heading")

                    Text("Register to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Group {
                        TextField("Username", text: $username)
                            .accessibilityLabel("Username field")

                        TextField("Email", text: $email)
                            .accessibilityLabel("Email field")

                        PasswordField(placeholder: "Password", text: $password)
                        PasswordField(placeholder: "Confirm Password", text: $confirmPassword)



                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }

                    Button(action: handleSignUp) {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    .padding(.top, 10)
                    .accessibilityLabel("Register button")
                    .accessibilityAddTraits(.isButton)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)

                Spacer()
            }

            if showSuccessBanner {
                VStack {
                    HStack {
                        Spacer()
                        Text("Signed Up Successfully!")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                        Spacer()
                    }
                    .padding(.top, 60)
                    Spacer()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showSuccessBanner)
            }
        }
    }
    
    private func handleSignUp() {
        if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "All fields must be filled"
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        //Check if the username already exists
        if DatabaseManager.shared.checkUserExists(username: username) {
            errorMessage = "Username already taken"
            return
        }
        
        
        let success = DatabaseManager.shared.insertUser(username: username, email: email, password: password)
        //Insert into SQLite Database
        if success {
            isAuthenticated = true
            errorMessage = nil
            showSuccessBanner = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSuccessBanner = false
            }
        } else {
            errorMessage = "Failed to sign up. Please try again."
        }
    }
}
struct PasswordField: View {
    var placeholder: String
    @Binding var text: String
    @State private var isSecure = true

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.oneTimeCode)
                    .accessibilityLabel("Password field hidden")
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(.none)
                    .accessibilityLabel("Password field")
            }

            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
