import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section(header: Text("Appearance").font(settings.font)) {
                Toggle("Dark Mode", isOn: $settings.isDarkMode)
                    .font(settings.font)
            }

            Section(header: Text("Font Size").font(settings.font)) {
                Slider(value: $settings.fontSize, in: 12...30, step: 1)
                Text("Preview: \(Int(settings.fontSize)) pt")
                    .font(settings.font)
            }

            Section(header: Text("Preferences").font(settings.font)) {
                Picker("Measurement Unit", selection: $settings.measurementUnit) {
                    Text("Metric (kg, ml)").tag("Metric")
                    Text("Imperial (lbs, oz)").tag("Imperial")
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(settings.font)
            }

            Section {
                Text("All settings are saved automatically ✅")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsPage().environmentObject(AppSettings())
}
