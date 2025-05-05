
import XCTest
@testable import Asare

final class AsareTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testInsertUser() throws {
        let username = "testuser"
        let email = "testuser@example.com"
        let password = "password123"

        let success = DatabaseManager.shared.insertUser(username: username, email: email, password: password)

        XCTAssertTrue(success, "User should be successfully inserted")
        
        //Checking if the user exists in the database
        DatabaseManager.shared.fetchAllUsers { users in
            let userExists = users.contains { $0.username == username }
            XCTAssertTrue(userExists, "User should be present in the database after insertion")
        }
    }

    func testValidateUser() throws {
        let username = "testuser"
        let password = "password123"
        
        //Insert a user for validation
        let _ = DatabaseManager.shared.insertUser(username: username, email: "testuser@example.com", password: password)
        
        let isValidUser = DatabaseManager.shared.validateUser(username: username, password: password)
        XCTAssertTrue(isValidUser, "User credentials should be validated successfully")
    }

    func testCheckUserExists() throws {
        let username = "testuser"
        let _ = DatabaseManager.shared.insertUser(username: username, email: "testuser@example.com", password: "password123")
        
        let userExists = DatabaseManager.shared.checkUserExists(username: username)
        XCTAssertTrue(userExists, "User should exist in the database")
        
        let nonExistingUserExists = DatabaseManager.shared.checkUserExists(username: "nonexistentUser")
        XCTAssertFalse(nonExistingUserExists, "Non-existing user should not be found in the database")
    }

    func testPasswordHashing() throws {
        let username = "testuser"
        let password = "password123"
        
        let _ = DatabaseManager.shared.insertUser(username: username, email: "testuser@example.com", password: password)
        
        //Validate user login with correct password
        let isValidUser = DatabaseManager.shared.validateUser(username: username, password: password)
        XCTAssertTrue(isValidUser, "Password hashing should allow successful login with correct credentials")
        
        //Validate user login with incorrect password
        let isInvalidUser = DatabaseManager.shared.validateUser(username: username, password: "wrongpassword")
        XCTAssertFalse(isInvalidUser, "Password hashing should fail with incorrect credentials")
    }

    func testFetchAllUsers() throws {
        let username1 = "user1"
        let username2 = "user2"
        
        let _ = DatabaseManager.shared.insertUser(username: username1, email: "user1@example.com", password: "password123")
        let _ = DatabaseManager.shared.insertUser(username: username2, email: "user2@example.com", password: "password123")
        
        DatabaseManager.shared.fetchAllUsers { users in
            let usernames = users.map { $0.username }
            XCTAssertTrue(usernames.contains(username1), "User1 should be fetched from the database")
            XCTAssertTrue(usernames.contains(username2), "User2 should be fetched from the database")
        }
    }

    func testDeleteUser() throws {
        let username = "testuser"
        
        let _ = DatabaseManager.shared.insertUser(username: username, email: "testuser@example.com", password: "password123")
        
        let isDeleted = DatabaseManager.shared.deleteUser(username: username)
        XCTAssertTrue(isDeleted, "User should be deleted successfully")
        
        //Check if the user is no longer in the database
        DatabaseManager.shared.fetchAllUsers { users in
            let userExists = users.contains { $0.username == username }
            XCTAssertFalse(userExists, "Deleted user should not be found in the database")
        }
    }

    func testLogoutUser() throws {
        let username = "testuser"
        let _ = DatabaseManager.shared.insertUser(username: username, email: "testuser@example.com", password: "password123")
        let isLoggedIn = DatabaseManager.shared.validateUser(username: username, password: "password123")
        XCTAssertTrue(isLoggedIn, "User should be logged in after correct validation")
        
        DatabaseManager.shared.logoutUser()
        
        //Wait for the database update
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let user = DatabaseManager.shared.getCurrentUser()
            XCTAssertNil(user, "User should be logged out and there should be no current logged-in user")
        }
    }


}
