import SwiftUI

struct UsersListView: View {
    @State private var users: [(username: String, email: String)] = []
    
    var body: some View {
        VStack {
            Button(action: {
                // Insert a test user
                let _ = DatabaseManager.shared.insertUser(username: "john_doe", email: "john.doe@example.com", password: "password123")
                // Fetch all users and update the view
                self.fetchUsers()
            }) {
                Text("Insert User")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            List(users, id: \.username) { user in
                VStack(alignment: .leading) {
                    Text("Username: \(user.username)")
                    Text("Email: \(user.email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .onAppear {
            fetchUsers()
        }
    }
    
    private func fetchUsers() {
        DatabaseManager.shared.fetchAllUsers { fetchedUsers in
            self.users = fetchedUsers
        }
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView()
    }
}
