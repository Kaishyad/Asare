import SwiftUI

struct LoginPage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isNavigatingToSignUp = false
    
    var body: some View {
        VStack {
            Text("Login Page")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: handleLogin) {
                Text("Login")
                    .font(settings.font)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            // Navigate to SignUp page
            Button(action: {
                isNavigatingToSignUp = true
            }) {
                Text("Don't have an account? Sign Up")
                    .font(settings.font)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
            .padding(.top, 20)
            .background(
                NavigationLink("", destination: SignUpPage(isAuthenticated: $isAuthenticated), isActive: $isNavigatingToSignUp)
            )

            Spacer()
        }
        .padding()
    }
    
    private func handleLogin() {
        // Simulate a basic login check using saved UserDefaults data
        let storedUsername = UserDefaults.standard.string(forKey: "username")
        let storedPassword = UserDefaults.standard.string(forKey: "password")
        
        if username == storedUsername && password == storedPassword {
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            isAuthenticated = true
            errorMessage = nil
        } else {
            errorMessage = "Invalid username or password"
        }
    }
}

#Preview {
    LoginPage(isAuthenticated: .constant(false))
}
