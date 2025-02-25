import SwiftUI

struct UsersListView: View {
    @State private var users: [(username: String, email: String)] = []
    
    var body: some View {
        VStack {
            Button(action: {
                let _ = DatabaseManager.shared.insertUser(username: "john_doe", email: "john.doe@example.com", password: "password123")
                self.fetchUsers()
            }) {
                Text("Insert User")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            List {
                ForEach(users, id: \.username) { user in
                    VStack(alignment: .leading) {
                        Text("Username: \(user.username)")
                        Text("Email: \(user.email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .contextMenu {
                        Button(action: {
                            deleteUser(user.username)
                        }) {
                            Text("Delete User")
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteUserFromList)
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

    private func deleteUserFromList(at offsets: IndexSet) {
        if let index = offsets.first {
            let userToDelete = users[index]
            if DatabaseManager.shared.deleteUser(username: userToDelete.username) {
                users.remove(at: index)
            }
        }
    }

    private func deleteUser(_ username: String) {
        if DatabaseManager.shared.deleteUser(username: username) {
            users.removeAll { $0.username == username }
        }
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView()
    }
}
