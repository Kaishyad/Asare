import XCTest
@testable import Asare

class ConnectionManagerTests: XCTestCase {
    
    func testDatabaseConnection() {
        let connectionManager = ConnectionManager.shared
        let dbConnection = connectionManager.getConnection()
        
        //Check that the connection is not nil
        XCTAssertNotNil(dbConnection, "Database connection should be established.")
        
        if let path = dbConnection?.description {
            print("Database connection established at: \(path)")
        }
    }
}
