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
    private let isGridView = SQLite.Expression<Bool>("isGridView")

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("user_settings_database.sqlite")
                .path
            print("UserSettings Database path: \(path)")

            db = try Connection(path)
           // dropUserSettingsTable()
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
                t.column(isGridView, defaultValue: false)
            })
            print("UserSettings table ready!")
        } catch {
            print("Error creating user settings table: \(error)")
        }
    }
    func dropUserSettingsTable() {
        do {
            try db?.run(userSettings.drop(ifExists: true))
            print("Ingredients table dropped successfully!")
        } catch {
            print("Error dropping ingredients table: \(error.localizedDescription)")
        }
    }
    func saveUserSettings(username: String, darkMode: Bool, fontSize: Double, useDyslexiaFont: Bool, measurementUnit: Int, isGridView: Bool) {
        if let user = DatabaseManager.shared.getCurrentUser(), user.username == username {
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
                    print("Updated user settings for \(username).")
                } else {
                    try db?.run(userSettings.insert(
                        self.username <- username,
                        self.darkMode <- darkMode,
                        self.fontSize <- fontSize,
                        self.useDyslexiaFont <- useDyslexiaFont,
                        self.measurementUnit <- measurementUnit,
                        self.isGridView <- isGridView
                    ))
                    print("Inserted new user settings for \(username).")
                }
            } catch {
                print("Error saving user settings: \(error)")
            }
        } else {
            print("User does not exist in DatabaseManager. Cannot save settings.")
        }
    }



    func getUserSettings(username: String) -> (darkMode: Bool, fontSize: Double, useDyslexiaFont: Bool, measurementUnit: Int, isGridView: Bool)? {
        do {
            let userSettingsQuery = userSettings.filter(self.username == username)
            if let userSettingsRow = try db?.pluck(userSettingsQuery) {
                print("Fetched user settings for \(username): \(userSettingsRow)")
                return (
                    darkMode: userSettingsRow[darkMode],
                    fontSize: userSettingsRow[fontSize],
                    useDyslexiaFont: userSettingsRow[useDyslexiaFont],
                    measurementUnit: userSettingsRow[measurementUnit],
                    isGridView: userSettingsRow[isGridView]
                )
            } else {
                print("No user settings found for \(username).")
            }
        } catch {
            print("Error fetching user settings for \(username): \(error)")
        }
        return nil
    }

}
