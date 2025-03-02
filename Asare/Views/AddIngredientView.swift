import SwiftUI

struct AddIngredientsView: View {
    @Binding var ingredients: [(name: String, amount: String, measurement: String)] // Updated to include amount
    @State private var ingredientName: String = ""
    @State private var ingredientAmount: String = "" // Added amount field
    @State private var ingredientMeasurement: String = ""
    
    let fallbackMeasurements = ["cups", "tsp", "ml", "tbsp", "g", "oz", "kg"] // Predefined measurements

    var body: some View {
        VStack {
            Text("Add Ingredients")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Ingredient Name input
            TextField("Ingredient Name", text: $ingredientName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Ingredient Amount input
            TextField("Amount", text: $ingredientAmount)
                .keyboardType(.decimalPad) // Assuming amounts can be decimals
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Ingredient Measurement input
            TextField("Measurement", text: $ingredientMeasurement)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Picker for common measurements
            Picker("Measurement", selection: $ingredientMeasurement) {
                ForEach(fallbackMeasurements, id: \.self) { measurement in
                    Text(measurement)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            // Button to add the ingredient to the list
            Button(action: addIngredient) {
                Text("Add Ingredient")
                    .font(.body)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(ingredientName.isEmpty || ingredientAmount.isEmpty || ingredientMeasurement.isEmpty) // Disable button if fields are empty
            .padding(.top)

            // Displaying the list of ingredients
            List(ingredients, id: \.name) { ingredient in
                Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name)")
            }

            Spacer()

            // Done button to save and return to CreateRecipePage
            Button(action: {
                // Dismiss the AddIngredientsView and return to CreateRecipePage
            }) {
                Text("Done")
                    .font(.body)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
        .navigationBarTitle("Add Ingredients", displayMode: .inline)
    }

    // Function to add an ingredient to the list
    private func addIngredient() {
        // Add the new ingredient to the list
        ingredients.append((name: ingredientName, amount: ingredientAmount, measurement: ingredientMeasurement))

        // Reset input fields after adding ingredient
        ingredientName = ""
        ingredientAmount = ""
        ingredientMeasurement = ""
    }
}
