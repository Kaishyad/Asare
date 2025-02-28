//
//  ConnectionManager.swift
//  Asare
//
//  Created by Kaishya Desai on 26/02/2025.
//

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
            // You could move database table creation logic here if necessary, but it's better to keep it inside each manager
        } catch {
            print("Error initializing database connection: \(error)")
        }
    }

    func getConnection() -> Connection? {
        return db
    }
}
