import SwiftUI

struct LoginPage: View {
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var settings: AppSettings

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isNavigatingToSignUp = false
    @State private var isButtonDisabled = false

    var body: some View {
            VStack {

                Text("Asare")
                    .font(.system(size: 60, weight: .bold, design: .serif))
                    .kerning(2)
                    .foregroundStyle(
                        LinearGradient(colors: [Color.pink, Color.purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 10)
                    .padding(.top, 50)
                    .accessibilityAddTraits(.isHeader)


                VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .accessibilityLabel("Welcome Back Heading")


                    Text("Please sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)


                    VStack(spacing: 15) {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            .accessibilityLabel("Username field")


                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                            .accessibilityLabel("Password field hidden")

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }
                    }

                    
                    Button(action: {
                        handleLogin()
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    .disabled(isButtonDisabled)//disable button after tap
                    .onTapGesture {
                        isButtonDisabled = true
                        handleLogin()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isButtonDisabled = false
                        }
                    }
                    .accessibilityLabel("Login button")
                    .accessibilityAddTraits(.isButton)

                    Button(action: {
                        isNavigatingToSignUp = true
                    }) {
                        Text("Don't have an account? Register")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .accessibilityLabel(" Don't have an account? button")
                .accessibilityAddTraits(.isButton)

                Spacer()
            }

            NavigationLink(destination: SignUpPage(isAuthenticated: $isAuthenticated), isActive: $isNavigatingToSignUp) {
                EmptyView()
            }
            .hidden()
        
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
