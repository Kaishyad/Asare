import SwiftUI

struct AddIngredientsView: View {
    @Binding var ingredients: [(name: String, amount: String, measurement: String, section: String)]
    @State private var ingredientName: String = ""
    @State private var ingredientAmount: String = ""
    @State private var ingredientMeasurement: String = "cups"
    @State private var ingredientSection: String = "General"
    @State private var customMeasurement: String = ""
    @State private var isCustomMeasurement: Bool = false

    //Default measurement options
    let measurements = [
        "tsp", "tbsp", "cups", "oz", "gallons", "lbs", "ml", "l", "g"
    ]
    //Metric Measurement Units
        let metricMeasurements = [
            "tsp", "tbsp", "cups", "ml", "l", "g", "kg"
        ]

        //Imperial Measurement Units
        let imperialMeasurements = [
            "tsp", "tbsp", "oz", "cups", "pints", "gallons", "lbs", // Weight
            "tsp", "tbsp" // Common cooking units
        ]
    var body: some View {
        VStack {
            Text("Add Ingredients")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            TextField("Amount", text: $ingredientAmount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("Measurement", selection: $ingredientMeasurement) {
                ForEach(measurements, id: \.self) { measurement in
                    Text(measurement)
                }
                Text("Custom").tag("Custom")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if isCustomMeasurement {
                TextField("Enter Custom Measurement", text: $customMeasurement)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            TextField("Ingredient Name", text: $ingredientName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Section (e.g., Dry Ingredients, Dough, Salad)", text: $ingredientSection)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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
                            }
                        }
                    }
                }
                .onDelete(perform: deleteIngredients)
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Add Ingredients", displayMode: .inline)
        .onChange(of: ingredientMeasurement) { newValue in
            isCustomMeasurement = newValue == "Custom"
            if !isCustomMeasurement {
                customMeasurement = ""
            }
        }
    }

    private func addIngredient() {
        let measurementToUse = isCustomMeasurement ? customMeasurement : ingredientMeasurement
        
        ingredients.append((name: ingredientName, amount: ingredientAmount, measurement: measurementToUse, section: ingredientSection))

        ingredientName = ""
        ingredientAmount = ""
        ingredientMeasurement = "cups"
        ingredientSection = "General"
        customMeasurement = ""
    }

    private var groupedIngredients: [String: [(name: String, amount: String, measurement: String, section: String)]] {
        Dictionary(grouping: ingredients, by: { $0.section })
    }

    private func deleteIngredient(_ ingredient: (name: String, amount: String, measurement: String, section: String)) {
        if let index = ingredients.firstIndex(where: { $0.name == ingredient.name && $0.amount == ingredient.amount && $0.measurement == ingredient.measurement && $0.section == ingredient.section }) {
            ingredients.remove(at: index)
        }
    }

    private func deleteIngredients(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
}
