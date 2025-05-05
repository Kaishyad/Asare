import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var settings: AppSettings
    
    @State private var currentUser: (username: String, email: String)?
    @State private var hasLoadedUser = false
    @State private var hasLoadedUserSettings = false
    @State private var localDarkMode = false
    @State private var localFontSize = 20.0
    @State private var localUseDyslexiaFont = false
    @State private var localMeasurementUnit = 0
    @State private var localIsGridView = false
    
    @State private var isSaving = false
    @State private var hasLoaded = false
    private let settingsManager = UserSettingsManager.shared
    private func loadUserSettings() {
        guard !hasLoaded else { return }
        hasLoaded = true
        if let user = DatabaseManager.shared.getCurrentUser() {
            currentUser = user
            if let userSettings = settingsManager.getUserSettings(username: user.username) {
                localDarkMode = userSettings.darkMode
                localFontSize = userSettings.fontSize
                localUseDyslexiaFont = userSettings.useDyslexiaFont
                localMeasurementUnit = userSettings.measurementUnit
                localIsGridView = userSettings.isGridView
            }
        }
    }
    private func saveUserSettings() {
        guard !isSaving, let username = currentUser?.username else { return }
        isSaving = true
        
        let darkMode = localDarkMode
        let fontSize = localFontSize
        let useDyslexiaFont = localUseDyslexiaFont
        let measurementUnit = localMeasurementUnit
        let isGridView = localIsGridView
        DispatchQueue.global(qos: .background).async {
            settingsManager.saveUserSettings(
                username: username,
                darkMode: darkMode,
                fontSize: fontSize,
                useDyslexiaFont: useDyslexiaFont,
                measurementUnit: measurementUnit,
                isGridView: isGridView
            )
            DispatchQueue.main.async {
                settings.isDarkMode = darkMode
                settings.fontSize = fontSize
                settings.useDyslexiaFont = useDyslexiaFont
                settings.measurementUnit = measurementUnit
                isSaving = false
            }
        }
    }
    var body: some View {
        NavigationView {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(settings.largeTitleFont)
                .foregroundColor(.pink)
                .padding()
            //Code adapted from Sharma, 2022
            Form {
                Section(header: Text("Appearance").font(.system(size: localFontSize))) {
                    Toggle("Dark Mode", isOn: $localDarkMode)
                        .font(localUseDyslexiaFont
                            ? .custom("Dyslexie Regular", size: localFontSize)
                            : .system(size: localFontSize))
                        .tint(.pink)
                        .accessibilityLabel("Toggle Dark Mode")
                                                    .accessibilityAddTraits(.isButton)
                }
                Section(header: Text("Font & Accessibility").font(.system(size: localFontSize))) {
                    Slider(value: $localFontSize, in: 12...30, step: 1)
                        .accessibilityLabel("Font Size Slider")
                        .accessibilityValue("\(Int(localFontSize)) points")
                    Text("Preview: \(Int(localFontSize)) pt")
                        .font(localUseDyslexiaFont
                            ? .custom("Dyslexie Regular", size: localFontSize)
                            : .system(size: localFontSize))
                    Toggle("Use Dyslexia-Friendly Font", isOn: $localUseDyslexiaFont)
                        .font(localUseDyslexiaFont
                            ? .custom("Dyslexie Regular", size: localFontSize)
                            : .system(size: localFontSize))
                        .tint(.pink)
                        .accessibilityLabel("Toggle Dyslexia-Friendly Font")
                        .accessibilityAddTraits(.isButton)
                }
                Section(header: Text("Preferences").font(.system(size: localFontSize))) {
                    Picker("Measurement Unit", selection: $localMeasurementUnit) {
                        Text("Metric (kg, ml)").tag(0)
                            .font(localUseDyslexiaFont
                                ? .custom("Dyslexie Regular", size: localFontSize)
                                : .system(size: localFontSize))
                        Text("Imperial (lbs, oz)").tag(1)
                            .font(localUseDyslexiaFont
                                ? .custom("Dyslexie Regular", size: localFontSize)
                                : .system(size: localFontSize))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityLabel("Measurement Unit Picker")
                   // Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Use Grid View", isOn: $localIsGridView)
                            .font(localUseDyslexiaFont
                                ? .custom("Dyslexie Regular", size: localFontSize)
                                : .system(size: localFontSize))
                            .tint(.pink)
                        Text("Choose grid or list layout for the recipe page")
                            //.font(.system(size: 10))
                            .font(localUseDyslexiaFont
                                ? .custom("Dyslexie Regular", size: localFontSize)
                                : .system(size: localFontSize - 7))
                    }
                }
                Section {
                    Button(action: saveUserSettings) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                
                            } else {
                                Text("Save Settings")
                                    .font(.system(size: localFontSize))
                            }
                        }
                    }
                    .disabled(isSaving)
                    .accessibilityLabel("Save Settings Button")
                    .accessibilityAddTraits(.isButton)
                }
            }//End of Adaption
        }
      //  .navigationTitle("Settings")
        .task {
            if !hasLoadedUserSettings {
                hasLoadedUserSettings = true
                loadUserSettings()
            }
        }
        }
    }
}
