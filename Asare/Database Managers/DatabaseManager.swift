import SQLite
import Foundation
import CryptoKit // For password hashing

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    private let users = Table("users")
    private let id = Expression<Int64>("id")
    private let username = Expression<String>("username")
    private let email = Expression<String>("email")
    private let password = Expression<String>("password")
    private let isLoggedIn = Expression<Bool>("isLoggedIn")

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("app_database.sqlite")
                .path
            print("Database path: \(path)")

            db = try Connection(path)
            createUsersTable()
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    func resetDatabase() {
        do {
            // Get the database file path
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("app_database.sqlite")
                .path
            
            // Check if the file exists, and delete it
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

    private func createUsersTable() {
        do {
            // Ensure the table exists before interacting with it
            let exists = try db?.scalar("SELECT count(name) FROM sqlite_master WHERE type='table' AND name='users'") as? Int64 ?? 0

            if exists == 0 {
                // Table doesn't exist, so create it
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


    func checkColumnExists() {
        do {
            let tableInfo = try db?.prepare("PRAGMA table_info(\(users))")
            for column in tableInfo! {
                print(column[1]!) // Prints the column names in the users table
            }
        } catch {
            print("Error checking columns: \(error)")
        }
    }

    func updatePassword(username: String, newPassword: String) {
        let users = Table("users")
        let usernameColumn = Expression<String>("username")
        let passwordColumn = Expression<String>("password")
        
        let hashedNewPassword = hashPassword(newPassword) // Secure the password

        do {
            let userToUpdate = users.filter(usernameColumn == username)
            try db?.run(userToUpdate.update(passwordColumn <- hashedNewPassword))
            print("Password updated successfully!")
        } catch {
            print("Error updating password: \(error)")
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
        let usernameColumn = Expression<String>("username")
        let passwordColumn = Expression<String>("password")
        let isLoggedInColumn = Expression<Bool>("isLoggedIn")

        do {
            let query = users.filter(usernameColumn == username)
            if let user = try db?.pluck(query) {
                // Compare the hashed password
                if verifyPassword(input: password, stored: user[passwordColumn]) {
                    // Mark user as logged in
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
            // Retrieve the logged-in user
            let query = users.filter(isLoggedIn == true)
            if let user = try db?.pluck(query) {
                return (username: user[username], email: user[email])
            }
        } catch {
            print("Error fetching current user: \(error)")
        }
        return nil
    }


    func logoutUser() {
        guard let currentUser = getCurrentUser() else {
            print("No user is logged in")
            return
        }

        do {
            let user = users.filter(self.username == currentUser.username)
            try db?.run(user.update(isLoggedIn <- false))  // Mark user as logged out
            print("User logged out successfully!")
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

    func fetchAllUsers(completion: @escaping ([(username: String, email: String)]) -> Void) {
        do {
            // Fetch all users
            let allUsers = try db?.prepare(users)
            var usersList: [(username: String, email: String)] = []

            if let allUsers = allUsers {
                // Loop through and collect each user's info
                for user in allUsers {
                    usersList.append((username: user[username], email: user[email]))
                }
            } else {
                print("No users found in the database.")
            }
            
            // Call the completion handler with the result
            completion(usersList)
            
        } catch {
            print("Error fetching users: \(error)")
            // Return an empty list on error
            completion([])
        }
    }


    func isUserAuthenticated() -> Bool {
        do {
            // Check if any user has their 'isLoggedIn' field set to true
            let query = users.filter(isLoggedIn == true)
            if (try db?.pluck(query)) != nil {
                return true // There's an authenticated user
            }
        } catch {
            print("Error checking authentication: \(error)")
        }
        return false // No authenticated user found
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
