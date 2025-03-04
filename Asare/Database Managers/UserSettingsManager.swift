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
    private let measurementUnit = SQLite.Expression<String>("measurementUnit")

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("user_settings_database.sqlite")
                .path
            print("UserSettings Database path: \(path)")

            db = try Connection(path)
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
            })
            print("UserSettings table ready!")
        } catch {
            print("Error creating user settings table: \(error)")
        }
    }

    // Save user settings to the database, ensuring they are linked by username
    func saveUserSettings(username: String, darkMode: Bool, fontSize: Double, useDyslexiaFont: Bool, measurementUnit: String) {
        do {
            let userSettingsQuery = userSettings.filter(self.username == username)
            
            if try db?.pluck(userSettingsQuery) != nil {
                // Update if the settings already exist for this user
                try db?.run(userSettingsQuery.update(
                    self.darkMode <- darkMode,
                    self.fontSize <- fontSize,
                    self.useDyslexiaFont <- useDyslexiaFont,
                    self.measurementUnit <- measurementUnit
                ))
            } else {
                // Insert new settings for this user if they don't exist
                try db?.run(userSettings.insert(
                    self.username <- username,
                    self.darkMode <- darkMode,
                    self.fontSize <- fontSize,
                    self.useDyslexiaFont <- useDyslexiaFont,
                    self.measurementUnit <- measurementUnit
                ))
            }
        } catch {
            print("Error saving user settings: \(error)")
        }
    }

    // Fetch the settings for the specific user by username
    func getUserSettings(username: String) -> (darkMode: Bool, fontSize: Double, useDyslexiaFont: Bool, measurementUnit: String)? {
        do {
            let userSettingsQuery = userSettings.filter(self.username == username)
            if let userSettingsRow = try db?.pluck(userSettingsQuery) {
                return (
                    darkMode: userSettingsRow[darkMode],
                    fontSize: userSettingsRow[fontSize],
                    useDyslexiaFont: userSettingsRow[useDyslexiaFont],
                    measurementUnit: userSettingsRow[measurementUnit]
                )
            }
        } catch {
            print("Error fetching user settings: \(error)")
        }
        return nil
    }
}
