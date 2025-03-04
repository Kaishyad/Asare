import SwiftUI

struct RecipeDetailView: View {
    var recipe: (id: Int64, name: String, description: String, filters: [String])
    @Environment(\.presentationMode) var presentationMode
    @State private var ingredients: [(name: String, amount: String, measurement: String)] = []
    @State private var instructions: [(stepNumber: Int, instructionText: String)] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text(recipe.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top)

                // Display filters if any
                if !recipe.filters.isEmpty {
                    Text("Filters: \(recipe.filters.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                        .padding(.top)
                }

                // Display ingredients
                if !ingredients.isEmpty {
                    Text("Ingredients:")
                        .font(.headline)
                        .foregroundColor(.pink)
                        .padding(.top)
                    
                    ForEach(ingredients, id: \.name) { ingredient in
                        HStack {
                            Text(ingredient.name)
                                .font(.body)
                            Spacer()
                            Text(ingredient.measurement)
                                .font(.body)
                        }
                        .padding(.vertical, 5)
                    }
                } else {
                    Text("No ingredients available")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top)
                }

                // Display instructions if available
                if !instructions.isEmpty {
                    Text("Instructions:")
                        .font(.headline)
                        .foregroundColor(.pink)
                        .padding(.top)
                    
                    ForEach(instructions, id: \.stepNumber) { instruction in
                        Text("Step \(instruction.stepNumber): \(instruction.instructionText)")
                            .font(.body)
                            .padding(.vertical, 5)
                    }
                } else {
                    Text("No instructions available")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    deleteRecipe()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            fetchIngredients()
            fetchInstructions() // Fetch instructions when the view appears
        }
    }

    // Function to delete the recipe
    private func deleteRecipe() {
        let success = RecipeDatabaseManager.shared.deleteRecipe(name: recipe.name)
        if success {
            presentationMode.wrappedValue.dismiss() // Go back to RecipeView
        } else {
            print("Failed to delete recipe")
        }
    }

    // Fetch ingredients for the recipe when the view appears
    private func fetchIngredients() {
        ingredients = IngredientManager.shared.fetchIngredientsForRecipe(recipeId: recipe.id)
    }

    // Fetch instructions for the recipe
    private func fetchInstructions() {
        instructions = InstructionsManager.shared.fetchInstructions(recipeId: recipe.id)
    }
}
