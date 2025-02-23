import SwiftUI

struct ViewRecipesPage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipes: [(name: String, description: String, filters: [String])] = []

    var body: some View {
        VStack {
            Text("📖 All Recipes")
                .font(settings.font)
                .padding()

            // List of recipes
            List(recipes, id: \.name) { recipe in
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.headline)
                    Text(recipe.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if !recipe.filters.isEmpty {
                        Text("Filters: \(recipe.filters.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 5)
            }
            .onAppear {
                fetchRecipes()
            }

            Spacer()
        }
        .navigationTitle("Recipes")
        .padding()
    }

    private func fetchRecipes() {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }

        RecipeDatabaseManager.shared.fetchRecipesForUser(username: currentUser.username) { fetchedRecipes in
            self.recipes = fetchedRecipes
        }
    }
}
