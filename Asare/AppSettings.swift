import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("fontSize") var fontSize: Double = 16
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("measurementUnit") var measurementUnit: String = "Metric"

    // Dynamic Font Modifier
    var font: Font {
        Font.system(size: fontSize)
    }
}
