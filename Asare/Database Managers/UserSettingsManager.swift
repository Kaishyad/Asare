import SQLite
import Foundation

class UserSettingsManager {
    static let shared = UserSettingsManager()
    private var db: Connection?

    private let userSettings = Table("userSettings")
    private let username = SQLite.Expression<String>("username")
    private let darkMode = SQLite.Expression<Bool>("darkMode")
    private let fontSize = SQLite.Expression<Double>("fontSize")
    private let useDyslexiaFont = SQLite.Expression<Bool>("useDyslexiaFont")
    private let measurementUnit = SQLite.Expression<Int>("measurementUnit")
    private let isGridView = SQLite.Expression<Bool>("isGridView") // NEW COLUMN

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("user_settings_database.sqlite")
                .path
            print("UserSettings Database path: \(path)")

            db = try Connection(path)
            dropUserSettingsTable()
            createUserSettingsTable()
        } catch {
            print("Error initializing database: \(error)")
        }
    }

    private func createUserSettingsTable() {
        do {
            try db?.run(userSettings.create(ifNotExists: true) { t in
                t.column(username, unique: true)
                t.column(darkMode)
                t.column(fontSize)
                t.column(useDyslexiaFont)
                t.column(measurementUnit)
                t.column(isGridView, defaultValue: false) // Default to list view
            })
            print("UserSettings table ready!")
        } catch {
            print("Error creating user settings table: \(error)")
        }
    }
    func dropUserSettingsTable() {
        do {
            try db?.run(userSettings.drop(ifExists: true)) // Drops the table if it exists
            print("Ingredients table dropped successfully!")
        } catch {
            print("Error dropping ingredients table: \(error.localizedDescription)")
        }
    }
    func saveUserSettings(username: String, darkMode: Bool, fontSize: Double, useDyslexiaFont: Bool, measurementUnit: Int, isGridView: Bool) {
        do {
            let userSettingsQuery = userSettings.filter(self.username == username)
            
            if try db?.pluck(userSettingsQuery) != nil {
                try db?.run(userSettingsQuery.update(
                    self.darkMode <- darkMode,
                    self.fontSize <- fontSize,
                    self.useDyslexiaFont <- useDyslexiaFont,
                    self.measurementUnit <- measurementUnit,
                    self.isGridView <- isGridView
                ))
            } else {
                try db?.run(userSettings.insert(
                    self.username <- username,
                    self.darkMode <- darkMode,
                    self.fontSize <- fontSize,
                    self.useDyslexiaFont <- useDyslexiaFont,
                    self.measurementUnit <- measurementUnit,
                    self.isGridView <- isGridView
                ))
            }
        } catch {
            print("Error saving user settings: \(error)")
        }
    }

    func getUserSettings(username: String) -> (darkMode: Bool, fontSize: Double, useDyslexiaFont: Bool, measurementUnit: Int, isGridView: Bool)? {
        do {
            let userSettingsQuery = userSettings.filter(self.username == username)
            if let userSettingsRow = try db?.pluck(userSettingsQuery) {
                return (
                    darkMode: userSettingsRow[darkMode],
                    fontSize: userSettingsRow[fontSize],
                    useDyslexiaFont: userSettingsRow[useDyslexiaFont],
                    measurementUnit: userSettingsRow[measurementUnit],
                    isGridView: userSettingsRow[isGridView]
                )
            }
        } catch {
            print("Error fetching user settings: \(error)")
        }
        return nil
    }
}
