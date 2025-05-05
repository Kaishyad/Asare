
import XCTest
@testable import Asare

final class UserSettingsTests: XCTestCase {

        func testUpdateUserSettings() throws {
            let username = "testuser"
            
            //Start with some settings
            let initialFontSize: Double = 16
            let initialDarkMode = false
            UserSettingsManager.shared.saveUserSettings(
                username: username,
                darkMode: initialDarkMode,
                fontSize: initialFontSize,
                useDyslexiaFont: false,
                measurementUnit: 0,
                isGridView: false
            )

            //Update the settings
            let updatedFontSize: Double = 20
            let updatedDarkMode = true
            UserSettingsManager.shared.saveUserSettings(
                username: username,
                darkMode: updatedDarkMode,
                fontSize: updatedFontSize,
                useDyslexiaFont: true,
                measurementUnit: 1,
                isGridView: true
            )
            
            if let updatedSettings = UserSettingsManager.shared.getUserSettings(username: username) {
                XCTAssertEqual(updatedSettings.fontSize, updatedFontSize, "Font size should be updated correctly.")
                XCTAssertEqual(updatedSettings.darkMode, updatedDarkMode, "Dark mode should be updated correctly.")
            } else {
                XCTFail("Failed to update user settings.")
            }
        }
    
    func testDropUserSettingsTable() throws {
        UserSettingsManager.shared.dropUserSettingsTable()

        //Try to fetch the settings from the dropped table
        let username = "testuser"
        if let _ = UserSettingsManager.shared.getUserSettings(username: username) {
            XCTFail("The user settings table should have been dropped, and no settings should be found.")
        }
    }
}
