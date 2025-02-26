import SwiftUI

struct CreateRecipePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipeName: String = ""
    @State private var recipeDescription: String = ""
    @State private var selectedFilters: Set<String> = []
    @State private var customFilterName: String = ""
    @State private var allFilters: [String] = []
    @State private var isSaving = false
    @State private var isFiltersExpanded: Bool = false
    @State private var currentUser: String = ""
    @State private var isFavorite = false  // Used to track the favorite status
    @State private var recipeId: Int64?  // Ensure recipeId is properly stored

    var body: some View {
        VStack {
            Text("Create New Recipe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding()

            TextField("Enter Recipe Name", text: $recipeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()

            TextField("Enter Recipe Description", text: $recipeDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()

            // Favorite Toggle
            Toggle(isOn: $isFavorite) {
                Text("Favorite")
                    .font(settings.font)
                    .foregroundColor(.pink)
            }
            .toggleStyle(SwitchToggleStyle(tint: .pink))
            .padding()
            .disabled(recipeId == nil)  // Disable toggle if recipe isn't saved yet
            .onChange(of: isFavorite) { newValue in
                // Update the favorite status in the database when the toggle changes
                if let recipeId = recipeId {
                    if newValue {
                        _ = RecipeDatabaseManager.shared.addFavorite(recipeId: recipeId, username: currentUser)
                    } else {
                        _ = RecipeDatabaseManager.shared.removeFavorite(recipeId: recipeId, username: currentUser)
                    }
                }
            }

            // Filters Section
            VStack(alignment: .leading) {
                Button(action: { isFiltersExpanded.toggle() }) {
                    HStack {
                        Text("Filters: \(selectedFilters.isEmpty ? "None" : selectedFilters.joined(separator: ", "))")
                            .font(settings.font)
                            .foregroundColor(.pink)
                        Spacer()
                        Image(systemName: isFiltersExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.pink)
                    }
                    .padding(.top)
                }

                if isFiltersExpanded {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(allFilters, id: \.self) { filter in
                                HStack {
                                    Button(action: { toggleFilter(filter) }) {
                                        Image(systemName: selectedFilters.contains(filter) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedFilters.contains(filter) ? .pink : .gray)
                                    }
                                    .padding(.trailing, 5)

                                    Text(filter)

                                    Spacer()

                                    Button(action: { deleteFilter(filter) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 5)
                            }

                            // Add Custom Filter
                            HStack {
                                TextField("Custom Filter", text: $customFilterName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(settings.font)
                                    .padding()

                                Button(action: addCustomFilter) {
                                    Text("Add Filter")
                                        .font(settings.font)
                                        .padding()
                                        .background(Color.pink)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(customFilterName.isEmpty)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            .padding()

            // Save Recipe Button
            Button(action: saveRecipe) {
                Text(isSaving ? "Saving..." : "Save Recipe")
                    .font(settings.font)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isSaving || recipeName.isEmpty || recipeDescription.isEmpty)

            Spacer()
        }
        .navigationTitle("New Recipe")
        .padding()
        .onAppear {
            loadFilters()
            if let user = DatabaseManager.shared.getCurrentUser() {
                self.currentUser = user.username
            }
        }
    }

    private func saveRecipe() {
        guard !currentUser.isEmpty else {
            print("No user logged in")
            return
        }

        isSaving = true

        if let newRecipeId = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser,
            name: recipeName,
            description: recipeDescription,
            selectedFilters: Array(selectedFilters)
        ) {
            print("Recipe saved successfully!")
            recipeId = newRecipeId  // Assign new recipeId for favoriting
            loadFavoriteStatus()    // Now recipeId is valid, so we check if it's a favorite
        } else {
            print("Failed to save recipe")
        }

        isSaving = false
    }

    private func loadFavoriteStatus() {
        guard let recipeId = recipeId else { return }
        isFavorite = RecipeDatabaseManager.shared.isFavorite(recipeId: recipeId, username: currentUser)
    }

    private func loadFilters() {
        allFilters = RecipeDatabaseManager.shared.getAllFilters()
    }

    private func addCustomFilter() {
        if !customFilterName.isEmpty {
            let success = RecipeDatabaseManager.shared.addFilter(name: customFilterName)
            if success {
                loadFilters()
                customFilterName = ""
            } else {
                print("Failed to add filter to database")
            }
        }
    }

    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }

    private func deleteFilter(_ filter: String) {
        let success = RecipeDatabaseManager.shared.deleteFilter(name: filter)
        if success {
            withAnimation {
                allFilters.removeAll { $0 == filter }
                selectedFilters.remove(filter)
            }
        } else {
            print("Failed to delete filter")
        }
    }
}
