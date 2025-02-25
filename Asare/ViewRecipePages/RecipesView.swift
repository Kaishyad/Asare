import SwiftUI

struct RecipesView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipes: [(name: String, description: String, filters: [String])] = []
    @State private var searchText: String = ""
    @State private var isGridView: Bool = false
    @State private var favoriteStates: [Bool] = []
    
    let allFilters = RecipeDatabaseManager.shared.getAllFilters()
    @State private var selectedFilters: [String] = [] // Tracks user-selected filters
    
    var filteredRecipes: [(name: String, description: String, filters: [String])] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilters = selectedFilters.isEmpty || selectedFilters.allSatisfy { filter in
                recipe.filters.contains(filter)
            }
            
            return matchesSearch && matchesFilters
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Get Cookin'")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .padding(.horizontal)
                
                HStack {
                    TextField("Search Recipes", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                    
                    Button(action: {
                        isGridView.toggle()
                    }) {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                            .font(.title2)
                            .padding(10)
                            .background(Color.pink.opacity(0.2))
                            .foregroundColor(.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(allFilters, id: \.self) { filter in
                            Button(action: {
                                if selectedFilters.contains(filter) {
                                    selectedFilters.removeAll { $0 == filter }
                                } else {
                                    selectedFilters.append(filter)
                                }
                            }) {
                                Text(filter)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedFilters.contains(filter) ? Color.pink : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedFilters.contains(filter) ? .white : .black)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if isGridView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                        ForEach(0..<filteredRecipes.count, id: \.self) { index in
                            let recipe = filteredRecipes[index]

                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                VStack {
                                    Text(recipe.name)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding(.top)

                                    Text(recipe.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)

                                    if !recipe.filters.isEmpty {
                                        Text("Filters: \(recipe.filters.joined(separator: ", "))")
                                            .font(.subheadline)
                                            .foregroundColor(.pink)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Button(action: {
                                        favoriteStates[index].toggle()
                                    }) {
                                        Image(systemName: favoriteStates[index] ? "heart.fill" : "heart")
                                            .foregroundColor(favoriteStates[index] ? .pink : .gray)
                                            .font(.title)
                                    }
                                    .padding(.top)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredRecipes, id: \.name) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                VStack(alignment: .leading) {
                                    Text(recipe.name)
                                        .font(.headline)
                                    Text(recipe.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    if !recipe.filters.isEmpty {
                                        Text("Filters: \(recipe.filters.joined(separator: ", "))")
                                            .font(.subheadline)
                                            .foregroundColor(.pink)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
                Spacer()
            }
            .onAppear {
                fetchRecipes()
            }
        }
    }

    private func fetchRecipes() {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }

        RecipeDatabaseManager.shared.fetchRecipesForUser(username: currentUser.username) { fetchedRecipes in
            self.recipes = fetchedRecipes
            self.favoriteStates = Array(repeating: false, count: fetchedRecipes.count)
        }
    }
}
