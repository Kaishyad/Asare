import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section(header: Text("Appearance").font(settings.font)) {
                Toggle("Dark Mode", isOn: $settings.isDarkMode)
                    .font(settings.font)
                    .accessibilityLabel("Toggle Dark Mode")
            }

            Section(header: Text("Font & Accessibility").font(settings.font)) {
                Slider(value: $settings.fontSize, in: 12...30, step: 1)
                    .accessibilityValue("\(Int(settings.fontSize)) points")
                Text("Preview: \(Int(settings.fontSize)) pt")
                    .font(settings.font)

                Toggle("Use Dyslexia-Friendly Font", isOn: $settings.useDyslexiaFont)
                    .font(settings.font)
                    .accessibilityLabel("Enable Dyslexia-Friendly Font")
            }

            Section(header: Text("Preferences").font(settings.font)) {
                Picker("Measurement Unit", selection: $settings.measurementUnit) {
                    Text("Metric (kg, ml)").tag("Metric")
                    Text("Imperial (lbs, oz)").tag("Imperial")
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(settings.font)
                .accessibilityLabel("Measurement Unit Selection")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsPage().environmentObject(AppSettings())
}
