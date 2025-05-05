import SwiftUI

struct AddIngredientsView: View {
    @EnvironmentObject var settings: AppSettings

    @Binding var ingredients: [(name: String, amount: String, measurement: String, section: String)]

    @State private var ingredientName: String = ""
    @State private var ingredientAmount: String = ""
    @State private var ingredientMeasurement: String = "cups"
    @State private var ingredientSection: String = "General"

    @State private var customMeasurement: String = ""
    @State private var isCustomMeasurement: Bool = false

    @State private var newSectionName: String = ""
    @State private var customSections: [String] = ["General"]

    @FocusState private var amountIsFocused: Bool
    @FocusState private var nameIsFocused: Bool
    @FocusState private var customMeasurementIsFocused: Bool
    @FocusState private var sectionNameIsFocused: Bool
    //based on the preference the user set in settings
    let metricMeasurements = ["tsp", "tbsp", "cups", "ml", "l", "g",]
    let imperialMeasurements = ["tsp", "tbsp", "cups", "oz", "fl oz"]

    var filteredMeasurements: [String] {
        let base = settings.measurementUnit == 0 ? metricMeasurements : imperialMeasurements
        return Array(base.prefix(6)) + ["Custom"]
    }

    @State private var didInitialLoad = false
    private let settingsManager = UserSettingsManager.shared

    func loadUserSettings() { //make sure settings up to date
        guard !didInitialLoad else { return }
        didInitialLoad = true

        if let user = DatabaseManager.shared.getCurrentUser(),
           let userSettings = settingsManager.getUserSettings(username: user.username) {
            settings.isDarkMode = userSettings.darkMode
            settings.fontSize = userSettings.fontSize
            settings.useDyslexiaFont = userSettings.useDyslexiaFont
            settings.measurementUnit = userSettings.measurementUnit
        }
    }

    var body: some View {
        VStack {
            Text("Add Ingredients")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .accessibilityAddTraits(.isHeader)


            TextField("Amount", text: $ingredientAmount)
                .keyboardType(.decimalPad)
                .padding()
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(amountIsFocused ? Color.pink : Color(white: 0.9), lineWidth: 1)
                )
                .focused($amountIsFocused)

            Picker("Measurement", selection: $ingredientMeasurement) {
                ForEach(filteredMeasurements, id: \.self) { measurement in
                    if measurement == "Custom" {
                        Image(systemName: "plus").tag(measurement)
                    } else {
                        Text(measurement).tag(measurement)
                    }
                }

            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if isCustomMeasurement {
                TextField("Enter Custom Measurement", text: $customMeasurement)
                    .padding()
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(customMeasurementIsFocused ? Color.pink : Color(white: 0.9), lineWidth: 1)
                    )
                    .focused($customMeasurementIsFocused)
            }

            TextField("Ingredient Name", text: $ingredientName)
                .padding()
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(nameIsFocused ? Color.pink : Color(white: 0.9), lineWidth: 1)
                )
                .focused($nameIsFocused)

            Picker("Section", selection: $ingredientSection) {
                ForEach(customSections, id: \.self) { section in
                    Text(section).tag(section)
                }
                Text("Custom").tag("Custom")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if ingredientSection == "Custom" {
                HStack {
                    TextField("Enter Custom Section", text: $newSectionName)
                        .padding(.horizontal)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(sectionNameIsFocused ? Color.pink : Color(white: 0.9), lineWidth: 1)
                        )
                        .focused($sectionNameIsFocused)

                    Button("Add Section") {
                        guard !newSectionName.isEmpty else { return }
                        if !customSections.contains(newSectionName) {
                            customSections.append(newSectionName)
                        }
                        ingredientSection = newSectionName
                        newSectionName = ""
                    }
                    .padding(8)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }

            Button(action: addIngredient) {
                Text("Add Ingredient")
                    .font(.body)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(ingredientName.isEmpty || ingredientAmount.isEmpty || (ingredientMeasurement.isEmpty && !isCustomMeasurement))
            .padding(.top)
            .accessibilityAddTraits(.isButton)


            List {
                ForEach(groupedIngredients.keys.sorted(), id: \.self) { section in
                    Section(header: Text(section).font(.headline)) {
                        ForEach(groupedIngredients[section] ?? [], id: \.name) { ingredient in
                            HStack {
                                Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name)")
                                Spacer()
                                Button(action: {
                                    deleteIngredient(ingredient)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .padding(5)
                                }
                                .accessibilityAddTraits(.isButton)

                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadUserSettings()
        }
        .onChange(of: ingredientMeasurement) { newValue in
            isCustomMeasurement = newValue == "Custom"
            if !isCustomMeasurement {
                customMeasurement = ""
            }
        }
    }

    private func addIngredient() {
        guard !ingredientName.isEmpty, !ingredientAmount.isEmpty else { return }

        if !newSectionName.isEmpty && !customSections.contains(newSectionName) {
            customSections.append(newSectionName)
            ingredientSection = newSectionName
        }

        let measurementToUse = isCustomMeasurement ? customMeasurement : ingredientMeasurement

        ingredients.append((name: ingredientName, amount: ingredientAmount, measurement: measurementToUse, section: ingredientSection))

        ingredientName = ""
        ingredientAmount = ""
        ingredientMeasurement = "cups"
        customMeasurement = ""
        newSectionName = ""
    }

    private var groupedIngredients: [String: [(name: String, amount: String, measurement: String, section: String)]] {
        Dictionary(grouping: ingredients, by: { $0.section })
    }

    private func deleteIngredient(_ ingredient: (name: String, amount: String, measurement: String, section: String)) {
        if let index = ingredients.firstIndex(where: {
            $0.name == ingredient.name &&
            $0.amount == ingredient.amount &&
            $0.measurement == ingredient.measurement &&
            $0.section == ingredient.section
        }) {
            ingredients.remove(at: index)
        }
    }

    private func deleteIngredients(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
}
