import SwiftUI
import CoreHaptics

class AppSettings: ObservableObject {
    @AppStorage("fontSize") var fontSize: Double = 16
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("measurementUnit") var measurementUnit: Int = 0
    @AppStorage("reduceMotion") var reduceMotion: Bool = false
    @AppStorage("voiceOverEnabled") var voiceOverEnabled: Bool = false
    @AppStorage("useDyslexiaFont") var useDyslexiaFont: Bool = false
    @AppStorage("colorblindMode") var colorblindMode: Bool = false
    @AppStorage("isGridView") var isGridView: Bool = false // 🔹 Added this

    var measurementUnitString: String {
        return measurementUnit == 0 ? "Metric" : "Imperial"
    }

    var font: Font {
        useDyslexiaFont ? Font.custom("OpenDyslexic", size: fontSize) : Font.system(size: fontSize)
    }
    
    var textColor: Color {
        colorblindMode ? Color.yellow : Color.primary
    }

    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

