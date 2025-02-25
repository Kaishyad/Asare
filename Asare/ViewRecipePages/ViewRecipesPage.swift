import SwiftUI

struct ViewRecipesPage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipes: [(name: String, description: String, filters: [String])] = []
    @State private var searchText: String = "" // Search bar text

    var filteredRecipes: [(name: String, description: String, filters: [String])] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText) ||
                recipe.filters.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }

    var body: some View {
        Text("📖 All Recipes")
            .font(settings.font)
            .padding()
//        VStack {
//            Text("📖 All Recipes")
//                .font(settings.font)
//                .padding()
//
//            List {
//                ForEach(filteredRecipes, id: \.name) { recipe in
//                    VStack(alignment: .leading) {
//                        Text(recipe.name)
//                            .font(.headline)
//                        Text(recipe.description)
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//
//                        if !recipe.filters.isEmpty {
//                            Text("Filters: \(recipe.filters.joined(separator: ", "))")
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .padding(.vertical, 5)
//                }
//                .onDelete(perform: deleteRecipe) // Enable swipe-to-delete
//            }
//            .searchable(text: $searchText, prompt: "Search Recipes") // Add search bar
//            .onAppear {
//                fetchRecipes()
//            }
//
//            Spacer()
//        }
//        .navigationTitle("Recipes")
//        .padding()
//    }
//
//    private func fetchRecipes() {
//        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
//            print("No user logged in")
//            return
//        }
//
//        RecipeDatabaseManager.shared.fetchRecipesForUser(username: currentUser.username) { fetchedRecipes in
//            self.recipes = fetchedRecipes
//        }
//    }
//
//    private func deleteRecipe(at offsets: IndexSet) {
//        for index in offsets {
//            let recipeName = filteredRecipes[index].name
//            let success = RecipeDatabaseManager.shared.deleteRecipe(name: recipeName)
//            if success {
//                recipes.removeAll { $0.name == recipeName } // Remove from UI if deletion succeeds
//            } else {
//                print("Failed to delete recipe: \(recipeName)")
//            }
//        }
    }
}
