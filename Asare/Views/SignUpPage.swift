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
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: handleSignUp) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .overlay(
                VStack {
                    if showSuccessBanner {
                        Text("Signed Up Successfully!")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut)
                    }
                }, alignment: .top
            )
        }
    }
    
    private func handleSignUp() {
        // Basic validation
        if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "All fields must be filled"
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        // Check if the username already exists
        if DatabaseManager.shared.checkUserExists(username: username) {
            errorMessage = "Username already taken"
            return
        }
        
        // Insert into SQLite Database
        let success = DatabaseManager.shared.insertUser(username: username, email: email, password: password)
        
        if success {
            isAuthenticated = true
            errorMessage = nil
            showSuccessBanner = true
            
            // Hide success banner after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSuccessBanner = false
            }
        } else {
            errorMessage = "Failed to sign up. Please try again."
        }
    }
}

#Preview {
    SignUpPage(isAuthenticated: .constant(false))
}
