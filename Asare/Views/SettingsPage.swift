import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var currentUser: (username: String, email: String)?
    @State private var isSaving = false

    private let settingsManager = UserSettingsManager.shared

    func loadUserSettings() {
        if let user = DatabaseManager.shared.getCurrentUser() {
            currentUser = user
            if let userSettings = settingsManager.getUserSettings(username: user.username) {
                settings.isDarkMode = userSettings.darkMode
                settings.fontSize = userSettings.fontSize
                settings.useDyslexiaFont = userSettings.useDyslexiaFont
                settings.measurementUnit = userSettings.measurementUnit
                settings.isGridView = userSettings.isGridView // Load Grid/List preference
            }
        }
    }

    func saveUserSettings() {
        guard let username = currentUser?.username else { return }
        
        isSaving = true
        
        DispatchQueue.global(qos: .background).async {
            settingsManager.saveUserSettings(
                username: username,
                darkMode: settings.isDarkMode,
                fontSize: settings.fontSize,
                useDyslexiaFont: settings.useDyslexiaFont,
                measurementUnit: settings.measurementUnit,
                isGridView: settings.isGridView
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isSaving = false
            }
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Appearance").font(settings.font)) {
                Toggle("Dark Mode", isOn: $settings.isDarkMode)
                    .font(settings.font)
                    .tint(.pink)
                    .accessibilityLabel("Toggle Dark Mode")
            }

            Section(header: Text("Font & Accessibility").font(settings.font)) {
                Slider(value: $settings.fontSize, in: 12...30, step: 1)
                    .accessibilityValue("\(Int(settings.fontSize)) points")
                Text("Preview: \(Int(settings.fontSize)) pt")
                    .font(settings.font)

                Toggle("Use Dyslexia-Friendly Font", isOn: $settings.useDyslexiaFont)
                    .font(settings.font)
                    .tint(.pink)
                    .accessibilityLabel("Enable Dyslexia-Friendly Font")
            }

            Section(header: Text("Preferences").font(settings.font)) {
                Picker("Measurement Unit", selection: $settings.measurementUnit) {
                    Text("Metric (kg, ml)").tag(0)
                    Text("Imperial (lbs, oz)").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(settings.font)
                .accessibilityLabel("Measurement Unit Selection")

                Toggle("Use Grid View", isOn: $settings.isGridView)
                    .font(settings.font)
                    .tint(.pink)
                    .accessibilityLabel("Toggle Grid/List View")
            }

            Section {
                Button(action: saveUserSettings) {
                    HStack {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save Settings")
                                .font(settings.font)
                        }
                    }
                }
                .disabled(isSaving) 
            }
        }
        .navigationTitle("Settings")
        .onAppear(perform: loadUserSettings)
    }
}
