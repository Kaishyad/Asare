
import SQLite
import Foundation

class ConnectionManager {
    static let shared = ConnectionManager()
    private var db: Connection?

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("app_database.sqlite")
                .path
            print("Database path: \(path)")

            db = try Connection(path)
            //better to keep connections it inside it's own manager
        } catch {
            print("Error initializing database connection: \(error)")
        }
    }

    func getConnection() -> Connection? {
        return db
    }
}
