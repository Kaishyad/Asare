import SQLite
import Foundation
import CryptoKit //password hashing

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private let users = Table("users")
        private let recipes = Table("recipes")
        private let id = SQLite.Expression<Int64>("id")
        private let username = SQLite.Expression<String>("username")
        private let email = SQLite.Expression<String>("email")
        private let password = SQLite.Expression<String>("password")
        private let isLoggedIn = SQLite.Expression<Bool>("isLoggedIn")
     

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("app_database.sqlite")
                .path
            print("Database path: \(path)")

            db = try Connection(path)
          //  dropUsersTable()
            createUsersTable()
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    private func createUsersTable() {
        do {
            let exists = try db?.scalar("SELECT count(name) FROM sqlite_master WHERE type='table' AND name='users'") as? Int64 ?? 0

            if exists == 0 {
                try db?.run(users.create { t in
                    t.column(id, primaryKey: true)
                    t.column(username, unique: true)
                    t.column(email, unique: true)
                    t.column(password)
                    t.column(isLoggedIn, defaultValue: false)
                })
                print("Users table created!")
            } else {
                print("Users table already exists!")
            }
        } catch {
            print("Error creating users table: \(error)")
        }
    }
    private func dropUsersTable() {
        do {
            try db?.run("DROP TABLE IF EXISTS users")
            print("Filters table dropped successfully!")
        } catch {
            print("Error dropping filters table: \(error)")
        }
    }
    
    


        func fetchAllUsers(completion: @escaping ([(username: String, email: String)]) -> Void) {
            do {
                let allUsers = try db?.prepare(users)
                var usersList: [(username: String, email: String)] = []

                if let allUsers = allUsers {
                    for user in allUsers {
                        usersList.append((username: user[username], email: user[email]))
                    }
                } else {
                    print("No users found in the database.")
                }
                
                completion(usersList)
            } catch {
                print("Error fetching users: \(error)")
                completion([])
            }
        }
    
    func resetDatabase() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("app_database.sqlite")
                .path
            
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
                print("Database file deleted successfully!")
            } else {
                print("No database file found at path: \(path)")
            }
        } catch {
            print("Error deleting database file: \(error)")
        }
    }


    func checkColumnExists() {
        do {
            let tableInfo = try db?.prepare("PRAGMA table_info(\(users))")
            for column in tableInfo! {
                print(column[1]!)
            }
        } catch {
            print("Error checking columns: \(error)")
        }
    }

    func updatePassword(username: String, newPassword: String) {
        let users = Table("users")
        let usernameColumn = SQLite.Expression<String>("username")
        let passwordColumn = SQLite.Expression<String>("password")
        
        let hashedNewPassword = hashPassword(newPassword)

        do {
            let userToUpdate = users.filter(usernameColumn == username)
            try db?.run(userToUpdate.update(passwordColumn <- hashedNewPassword))
            print("Password updated successfully!")
        } catch {
            print("Error updating password: \(error)")
        }
    }
    func deleteUser(username: String) -> Bool {
        let userToDelete = users.filter(self.username == username)
        
        do {
            let deletedRows = try db?.run(userToDelete.delete())
            if deletedRows ?? 0 > 0 {
                print("User \(username) deleted successfully!")
                return true
            } else {
                print("User \(username) not found.")
                return false
            }
        } catch {
            print("Error deleting user \(username): \(error)")
            return false
        }
    }




    // MARK: - User Functions

    func insertUser(username: String, email: String, password: String) -> Bool {
        let hashedPassword = hashPassword(password) // Secure the password

        do {
            try db?.run(users.insert(self.username <- username, self.email <- email, self.password <- hashedPassword))
            print("User registered successfully!")
            return true
        } catch {
            print("User registration failed: \(error)")
            return false
        }
    }

    func validateUser(username: String, password: String) -> Bool {
        let users = Table("users")
        let usernameColumn = SQLite.Expression<String>("username")
        let passwordColumn = SQLite.Expression<String>("password")
        let isLoggedInColumn = SQLite.Expression<Bool>("isLoggedIn")

        do {
            let query = users.filter(usernameColumn == username)
            if let user = try db?.pluck(query) {
                if verifyPassword(input: password, stored: user[passwordColumn]) {
                    let userToUpdate = users.filter(usernameColumn == username)
                    try db?.run(userToUpdate.update(isLoggedInColumn <- true)) // Set isLoggedIn to true
                    return true
                }
            }
        } catch {
            print("Error validating user: \(error)")
        }
        return false
    }





    func checkUserExists(username: String) -> Bool {
        do {
            let count = try db?.scalar(users.filter(self.username == username).count) ?? 0
            return count > 0
        } catch {
            print("Error checking user existence: \(error)")
            return false
        }
    }

    func getCurrentUser() -> (username: String, email: String)? {
        do {
            let query = users.filter(isLoggedIn == true)
            if let user = try db?.pluck(query) {
                //print("Current logged-in user: \(user[username])")  // Debug output
                return (username: user[username], email: user[email])
            } else {
                print("No user found with isLoggedIn = true")  // Debug output
            }
        } catch {
            print("Error fetching current user: \(error)")
        }
        return nil // Return nil if no user is logged in
    }


    func logoutUser() {
        guard let currentUser = getCurrentUser() else {
            print("No user is logged in")
            return
        }

        do {
            let userToUpdate = users.filter(self.username == currentUser.username)
            let rowsAffected = try db?.run(userToUpdate.update(isLoggedIn <- false)) ?? 0
            
            if rowsAffected > 0 {
                print("User \(currentUser.username) logged out successfully!")
            } else {
                print("No rows affected during logout. User may not have been logged in.")
            }
        } catch {
            print("Error during logout: \(error)")
        }
    }




    func testInsertUser() {
        let success = DatabaseManager.shared.insertUser(username: "testuser", email: "testuser@example.com", password: "password123")
        if success {
            print("User inserted successfully!")
        } else {
            print("User insertion failed.")
        }
    }

    
    func updateUsername(currentUsername: String, newUsername: String) -> Bool {
        let userToUpdate = users.filter(username == currentUsername)
        do {
            try db?.run(userToUpdate.update(username <- newUsername))
            print("Username updated successfully!")
            return true
        } catch {
            print("Error updating username: \(error)")
            return false
        }
    }

    func updateEmail(currentUsername: String, newEmail: String) -> Bool {
        let userToUpdate = users.filter(username == currentUsername)
        do {
            try db?.run(userToUpdate.update(email <- newEmail))
            print("Email updated successfully!")
            return true
        } catch {
            print("Error updating email: \(error)")
            return false
        }
    }


    func isUserAuthenticated() -> Bool {
        do {
            let query = users.filter(isLoggedIn == true)
            if (try db?.pluck(query)) != nil {
                return true
            }
        } catch {
            print("Error checking authentication: \(error)")
        }
        return false 
    }


    // MARK: - Security Functions

    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }

    private func verifyPassword(input: String, stored: String) -> Bool {
        return hashPassword(input) == stored
    }
}
