import SwiftUI
import CoreHaptics

class AppSettings: ObservableObject {
    @AppStorage("fontSize") var fontSize: Double = 20
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("measurementUnit") var measurementUnit: Int = 0
    @AppStorage("useDyslexiaFont") var useDyslexiaFont: Bool = false
    @AppStorage("isGridView") var isGridView: Bool = false
    @Published var currentUsername: String?
    @Published var currentUserEmail: String?
    
    //MARK: - Settings Page Preferences
    var measurementUnitString: String {
        measurementUnit == 0 ? "Metric" : "Imperial"
    }
    var textColor: Color {
        isDarkMode ? .white : .primary
    }
    func triggerHaptic() { 
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func loadCurrentUserIfNeeded() {
        guard currentUsername == nil else { return }
        if let user = DatabaseManager.shared.getCurrentUser() {
            currentUsername = user.username
            currentUserEmail = user.email
        }
    }

    //MARK: - UI FONTS
    var font: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize)
    }
    var fontCookNext: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize + 2, weight: .bold)
    }
    var headlineFont: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) :.system(size: fontSize - 3, weight: .semibold)
    }
    var pickbar: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) :.system(size: fontSize - 4, weight: .semibold)
    }
    var icons: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) :.system(size: fontSize - 6)
    }
    var subheadlineFont: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize - 5)
    }
    var largeTitleFont: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize + 20, weight: .bold)
    }
    var midTitleFont: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize + 10, weight: .bold)
    }
    var cookfont: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize + 10, weight: .semibold)
    }
    var smallTitleFont: Font {
        useDyslexiaFont ? Font.custom("Dyslexie Regular", size: fontSize) : .system(size: fontSize + 5, weight: .bold)
    }
    
}
