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
    @State private var currentUser: String = "" // Store logged-in username
    
    var body: some View {
        VStack {
            Text("Create New Recipe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            TextField("Enter Recipe Name", text: $recipeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()
            
            TextField("Enter Recipe Description", text: $recipeDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()
            
            // Filters Section
            VStack(alignment: .leading) {
                Button(action: { isFiltersExpanded.toggle() }) {
                    HStack {
                        Text("Filters: \(selectedFilters.isEmpty ? "None" : selectedFilters.joined(separator: ", "))")
                            .font(settings.font)
                            .foregroundColor(.pink) // Changed to pink
                        Spacer()
                        Image(systemName: isFiltersExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.pink) // Changed to pink
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
                                            .foregroundColor(selectedFilters.contains(filter) ? .pink : .gray) // Changed to pink
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
                            
                            HStack {
                                TextField("Custom Filter", text: $customFilterName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(settings.font)
                                    .padding()
                                
                                Button(action: addCustomFilter) {
                                    Text("Add Filter")
                                        .font(settings.font)
                                        .padding()
                                        .background(Color.pink) // Changed to pink
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
            
            Button(action: saveRecipe) {
                Text(isSaving ? "Saving..." : "Save Recipe")
                    .font(settings.font)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink) // Changed to pink
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
            if let currentUser = DatabaseManager.shared.getCurrentUser() {
                self.currentUser = currentUser.username
            }
        }
    }

    private func loadFilters() {
        allFilters = RecipeDatabaseManager.shared.getAllFilters()
    }
    
    private func addCustomFilter() {
        if !customFilterName.isEmpty {
            let success = RecipeDatabaseManager.shared.addFilter(name: customFilterName)
            if success {
                loadFilters() // Reload the filter list if the addition was successful
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
    
    private func saveRecipe() {
        guard !currentUser.isEmpty else {
            print("No user logged in")
            return
        }

        isSaving = true

        let success = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser,
            name: recipeName,
            description: recipeDescription,
            selectedFilters: Array(selectedFilters)
        )

        if success {
            print("Recipe saved successfully!")
            recipeName = ""
            recipeDescription = ""
            selectedFilters.removeAll()
        } else {
            print("Failed to save recipe")
        }

        isSaving = false
    }
    
    private func deleteFilter(_ filter: String) {
        let success = RecipeDatabaseManager.shared.deleteFilter(name: filter)
        if success {
            withAnimation {
                allFilters.removeAll { $0 == filter }
                selectedFilters.remove(filter) // Also remove it from selected filters
            }
        } else {
            print("Failed to delete filter")
        }
    }
}
