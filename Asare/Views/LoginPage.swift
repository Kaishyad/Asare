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
            
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
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
            
            Button(action: {
                isNavigatingToSignUp = true
            }) {
                Text("Don't have an account? Sign Up")
                    .font(settings.font)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
            .background(
                NavigationLink(destination: SignUpPage(isAuthenticated: $isAuthenticated), isActive: $isNavigatingToSignUp) {
                    EmptyView()
                }
                .hidden()
            )

            Spacer()
        }
        .padding()
    }
    
    private func handleLogin() {
        if DatabaseManager.shared.validateUser(username: username, password: password) {
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
