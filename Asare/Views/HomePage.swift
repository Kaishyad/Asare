import SwiftUI

struct HomePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var favoriteRecipes: [(id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?)] = []
    @State private var isLoading = true

    var body: some View {
        VStack {
            Text("Asare")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal)

            Text("Enjoy browsing and creating recipes!")
                .font(.system(size: 25, weight: .bold))
                .fontWeight(.bold)
                .foregroundColor(.pink)
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)

            HStack {
                Text("Favorites")
                    .font(settings.font)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)

            if isLoading {
                ProgressView("Loading Favorites...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding()
            } else if favoriteRecipes.isEmpty {
                Text("Add a favorite!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(favoriteRecipes, id: \.id) { recipe in
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
                                        .truncationMode(.tail)

                                    Text(formatTime(minutes: recipe.time))
                                        .font(.subheadline)
                                        .foregroundColor(.pink)

                                    if !recipe.filters.isEmpty {
                                        Text(" \(recipe.filters.joined(separator: ", "))")
                                            .font(.subheadline)
                                            .foregroundColor(.pink)
                                            .lineLimit(1)
                                    }

                                    Spacer()
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
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            fetchFavoriteRecipes()
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
            }
        }
    }
}
