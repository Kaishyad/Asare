import SwiftUI

struct RecipeDetailView: View {
    var recipe: (id: Int64, name: String, description: String, filters: [String])
    @Environment(\.presentationMode) var presentationMode

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
                
    
                if !recipe.filters.isEmpty {
                    Text("Filters: \(recipe.filters.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.pink)
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
}
