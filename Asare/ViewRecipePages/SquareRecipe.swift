import SwiftUI

struct SquareRecipe: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipes: [(name: String, description: String, filters: [String])] = []
    
    // To track the favorite state for each recipe
    @State private var favoriteStates: [Bool] // Added state to track whether heart is clicked
    
    let itemsPerRow = 2 // Number of items per row

    init() {
        _favoriteStates = State(initialValue: Array(repeating: false, count: 0)) // Initialize the favoriteStates array
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
//            // Using LazyVGrid to make the squares fill the available space
//            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20),
//                                GridItem(.flexible(), spacing: 20)], spacing: 20) {
//                ForEach(0..<recipes.count, id: \.self) { index in
//                    // Get the recipe using the index
//                    let recipe = recipes[index]
//                    
//                    // Square box style for each recipe
//                    VStack {
//                        Text(recipe.name)
//                            .font(.headline)
//                            .padding(.top)
//
//                        Text(recipe.description)
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                            .lineLimit(2)
//
//                        if !recipe.filters.isEmpty {
//                            Text("Filters: \(recipe.filters.joined(separator: ", "))")
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                                .lineLimit(1)
//                        }
//
//                        Spacer()
//
//                        // Heart icon button (click to toggle favorite state)
//                        Button(action: {
//                            favoriteStates[index].toggle() // Toggle favorite state for this recipe
//                        }) {
//                            Image(systemName: favoriteStates[index] ? "heart.fill" : "heart")
//                                .foregroundColor(favoriteStates[index] ? .pink : .gray) // Turn pink when favorite
//                                .font(.title)
//                        }
//                        .padding(.top)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, maxHeight: 200) // Make the square use the available space
//                    .background(Color.white)
//                    .cornerRadius(15)
//                    .shadow(radius: 5)
//                }
//            }
//            .padding()
//
//            Spacer()
//        }
//        .navigationTitle("Recipes")
//        .padding()
//        .onAppear {
//            fetchRecipes()
//        }
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
//            // Initialize the favoriteStates array with the number of recipes
//            self.favoriteStates = Array(repeating: false, count: fetchedRecipes.count)
//        }
    }
}
