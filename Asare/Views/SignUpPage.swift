import SwiftUI

struct SignUpPage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings  // Access settings via @EnvironmentObject
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var showSuccessBanner: Bool = false  // Banner for success

    var body: some View {
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
        
        // Store user information in UserDefaults (for demo purposes, in production use a secure backend)
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password") // NEVER store passwords in plaintext in production
        UserDefaults.standard.set(true, forKey: "isAuthenticated") // Mark user as authenticated
        
        // Set authentication status and show success banner
        isAuthenticated = true
        errorMessage = nil
        showSuccessBanner = true
        
        // After 3 seconds, hide the banner
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showSuccessBanner = false
        }
    }
}

#Preview {
    SignUpPage(isAuthenticated: .constant(false))
}
