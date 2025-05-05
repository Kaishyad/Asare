
import SwiftUI
struct RecipesView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var searchText: String = ""
    @State private var isGridView: Bool = false
    @State private var favoriteStates: [Bool] = []
    let allFilters = FilterManager.shared.getAllFilters()
    @State private var selectedFilters: [String] = []
    @State private var recipes: [(id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?, note: String?)] = []
    @State private var coverImages: [Int64: UIImage] = [:]
    @State private var ingredientsBySection: [String: [(name: String, amount: String, measurement: String)]] = [:]
    @FocusState private var nameIsFocused: Bool
    var filteredRecipes: [(id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?, note: String?)] {
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
                    .font(settings.largeTitleFont)
                    .foregroundColor(.pink)
                    .padding(.horizontal)
                    .padding(.top)
                    .accessibilityAddTraits(.isHeader)

                HStack {
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                        }
                        TextField("Search Recipes", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .font(settings.font)
                            .padding(.leading, 30)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(nameIsFocused ? Color.pink : Color(white: 0.9), lineWidth: 1))
                            .padding(.vertical, 10)
                            .focused($nameIsFocused)
                            .accessibilityAddTraits(.isSearchField)

                    }
                    Button(action: {
                        isGridView.toggle()
                        saveGridViewPreference()
                    }) {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                            .font(.title2)
                            .padding(10)
                            .background(Color.pink.opacity(0.2))
                            .foregroundColor(.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }.accessibilityAddTraits(.isButton)
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
                                    .font(settings.font)
                                    .background(selectedFilters.contains(filter) ? Color.pink : Color.gray.opacity(0.2))
                                    .foregroundColor(
                                        selectedFilters.contains(filter)
                                            ? .white
                                            : (settings.isDarkMode ? .white : .black)
                                    )
                                    .clipShape(Capsule())
                            }.accessibilityAddTraits(.isButton)
                        }
                    }
                    .padding(.horizontal)
                }
                if recipes.isEmpty {
                    VStack {
                        ProgressView("Add Recipes...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.001))
                    .edgesIgnoringSafeArea(.all)
                } else {
                    if isGridView {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                                ForEach(0..<filteredRecipes.count, id: \.self) { index in
                                    let recipe = filteredRecipes[index]
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe).font(settings.fontSize > 25 ? .title2 : settings.font)) {
                                        VStack {
                                            if let coverImage = coverImages[recipe.id] {
                                                Image(uiImage: coverImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 150, height: 120)
                                                    .clipped()
                                                    .cornerRadius(10)
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 150, height: 120)
                                                    .foregroundColor(.gray)
                                            }
                                            Text(recipe.name)
                                                .font(settings.headlineFont)
                                                //.foregroundColor(.black)
                                                .padding(.top, 5)
                                                .multilineTextAlignment(.center)
                                            Text(recipe.description)
                                                .font(settings.subheadlineFont)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                            Text(formatTime(minutes: recipe.time))
                                                .font(settings.subheadlineFont)
                                                .foregroundColor(.pink)
                                            Spacer()
                                            Button(action: {
                                                let isFavorite = favoriteStates[index]
                                                if isFavorite {
                                                    removeFromFavorites(recipeId: recipe.id)
                                                } else {
                                                    addToFavorites(recipeId: recipe.id)
                                                }
                                                favoriteStates[index].toggle()
                                            }) {
                                                Image(systemName: favoriteStates[index] ? "heart.fill" : "heart")
                                                    .foregroundColor(favoriteStates[index] ? .pink : .gray)
                                                    .font(.title)
                                            }
                                            .padding(.top)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(uiColor: .systemBackground))
                                        .cornerRadius(15)
                                        .shadow(color: settings.isDarkMode ? .clear : .black.opacity(0.2), radius: 5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.gray.opacity(settings.isDarkMode ? 0.4 : 0), lineWidth: 1)
                                        )

                                    }
                                }
                            }
                            .padding()
                        }
                    } else {
                        List {
                            ForEach(filteredRecipes, id: \.name) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe).font(settings.fontSize > 25 ? .title2 : settings.font)) {
                                    HStack {
                                        if let coverImage = coverImages[recipe.id] {
                                            Image(uiImage: coverImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipped()
                                                .cornerRadius(8)
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.gray)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(recipe.name)
                                                .font(settings.headlineFont)
                                                .fontWeight(.semibold)
                                            Text(recipe.description)
                                                .font(settings.subheadlineFont)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                            Text(formatTime(minutes: recipe.time))
                                                .font(settings.subheadlineFont)
                                                .foregroundColor(.pink)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .onAppear {
                fetchRecipes()
                loadGridViewPreference()
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
            fetchFavorites()
            fetchCoverImages()
        }
    }
    private func fetchCoverImages() {
        for recipe in recipes {
            if let imagePath = RecipeDatabaseManager.shared.getCoverImage(forRecipeId: recipe.id) {
                if let image = UIImage(contentsOfFile: imagePath) {
                    DispatchQueue.main.async {
                        self.coverImages[recipe.id] = image
                    }
                }
            }
        }
    }
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return mins > 0 ? "\(hours) hr \(mins) min" : "\(hours) hr"
        } else {
            return "\(mins) min"
        }
    }
    
    private func loadGridViewPreference() {
            guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
                print("No user logged in")
                return
            }
            
            if let userSettings = UserSettingsManager.shared.getUserSettings(username: currentUser.username) {
                self.isGridView = userSettings.isGridView
            }
        }
        private func saveGridViewPreference() {
            guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
                print("No user logged in")
                return
            }
            if let userSettings = UserSettingsManager.shared.getUserSettings(username: currentUser.username) {
                UserSettingsManager.shared.saveUserSettings(
                    username: currentUser.username,
                    darkMode: userSettings.darkMode,
                    fontSize: userSettings.fontSize,
                    useDyslexiaFont: userSettings.useDyslexiaFont,
                    measurementUnit: userSettings.measurementUnit,
                    isGridView: isGridView
                )
            }
        }
    private func fetchFavorites() {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }
        
        let favoriteIds = RecipeDatabaseManager.shared.getFavoritesForUser(username: currentUser.username)
        self.favoriteStates = recipes.map { recipe in
            return favoriteIds.contains(recipe.id)
        }
    }
    private func addToFavorites(recipeId: Int64) {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }
        let _ = RecipeDatabaseManager.shared.addFavorite(username: currentUser.username, recipeId: recipeId)
    }
    private func removeFromFavorites(recipeId: Int64) {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }
        let _ = RecipeDatabaseManager.shared.removeFavorite(username: currentUser.username, recipeId: recipeId)
    }
}
