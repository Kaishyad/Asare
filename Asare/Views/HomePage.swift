import SwiftUI
struct HomePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var favoriteRecipes: [(id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?, note: String?)] = []
    @State private var coverImages: [Int64: UIImage] = [:]
    @State private var isLoading = true
    var body: some View {
        VStack {
            Text("Asare")
                .font(.system(size: 80, weight: .bold, design: .serif))
                .kerning(2)
                .foregroundStyle(
                    LinearGradient(colors: [Color.pink, Color.purple], startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                .padding(.bottom, 10)
                .padding(.top, 30)
                .accessibilityLabel("Asare App Title")
                  .accessibilityAddTraits(.isHeader)
            Text("Recipes Made With Love")
                .font(.system(size: 25, weight: .bold))
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Recipes Made With Love heading")
                .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: CreateRecipePage().environmentObject(settings)) {
                    HStack {
                        Image(systemName: "book")
                        Text("Add a recipe")
                            .font(settings.font)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(5)
                .accessibilityLabel("Goes to add Recipe Page")
                .accessibilityAddTraits(.isButton)
                Spacer()
            
            HStack {
                Text("Favorites")
                    .font(settings.smallTitleFont)
                Spacer()
            }
            if isLoading {
                ProgressView("Loading Favorites...")
                    .font(settings.subheadlineFont)
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding()
            } else if favoriteRecipes.isEmpty {
                Text("Add a favorite!")
                    .font(settings.subheadlineFont)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(favoriteRecipes, id: \.id) { recipe in
                            ZStack { //Ajust the levels
                                NavigationLink(
                                    destination: RecipeDetailView(recipe: recipe).environmentObject(settings)
                                ) {
                                    VStack {
                                        if let coverImage = coverImages[recipe.id] {
                                            Image(uiImage: coverImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 120)
                                                .clipped()
                                                .cornerRadius(10)
                                                .accessibilityAddTraits(.isImage)

                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 120)
                                                .foregroundColor(.gray)
                                                .accessibilityLabel("Placeholder image")

                                        }

                                        Text(recipe.name)
                                            .font(settings.headlineFont)
                                            .foregroundColor(settings.textColor)
                                            .padding(.top)
                                    

                                        Text(formatTime(minutes: recipe.time))
                                            .font(settings.subheadlineFont)
                                            .foregroundColor(.pink)
                                    }
                                    .padding()
                                    .frame(width: 180, height: 250)
                                    .background(Color(uiColor: .systemBackground))
                                    .cornerRadius(15)
                                    .shadow(color: settings.isDarkMode ? .clear : .black.opacity(0.2), radius: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(settings.isDarkMode ? 0.4 : 0), lineWidth: 1)
                                    )
                                }                                .accessibilityAddTraits(.isButton)


                                //Overlay the play button only
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        NavigationLink(destination: CookModeView(recipeId: recipe.id).environmentObject(settings)) {
                                            Image(systemName: "play.fill")
                                                .font(.title2)
                                                .foregroundColor(.pink)
                                                .padding(10)
                                                .background(Color(uiColor: .systemBackground))
                                                .clipShape(Circle())
                                                .shadow(radius: 2)
                                        }.accessibilityAddTraits(.isButton)
                                    }
                                    .padding(12)
                                }
                                .frame(width: 180, height: 250)
                            }
                            .padding(.horizontal, 6)

                           // .padding()
                        }
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            fetchFavoriteRecipes()
        }
    }
    private func fetchCoverImages() {
        for recipe in favoriteRecipes {
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
    private func removeFromFavorites(recipeId: Int64) {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }
        let _ = RecipeDatabaseManager.shared.removeFavorite(username: currentUser.username, recipeId: recipeId)
    }
    private func fetchFavoriteRecipes() {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            isLoading = false
            return
        }
        let favoriteIds = RecipeDatabaseManager.shared.getFavoritesForUser(username: currentUser.username)
        RecipeDatabaseManager.shared.fetchRecipesForUser(username: currentUser.username) { allRecipes in
            DispatchQueue.main.async {
                self.favoriteRecipes = allRecipes.filter { favoriteIds.contains($0.id) }
                self.isLoading = false
                fetchCoverImages()
            }
        }
    }
}
