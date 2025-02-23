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
    
    var body: some View {
        VStack {
            Text("➕ Create New Recipe")
                .font(settings.font)
                .padding()
            
            TextField("Enter Recipe Name", text: $recipeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()
            
            TextField("Enter Recipe Description", text: $recipeDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()
            
            //Filters section with collapsible functionality
            VStack(alignment: .leading) {
                Button(action: {
                    isFiltersExpanded.toggle()
                }) {
                    HStack {
                        Text("Filters: \(selectedFilters.isEmpty ? "None" : selectedFilters.joined(separator: ", "))")
                            .font(settings.font)
                            .foregroundColor(.blue)
                        Spacer()
                        Image(systemName: isFiltersExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                    }
                    .padding(.top)
                }
                
                if isFiltersExpanded {
                    // Display all available filters to choose from
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(allFilters, id: \.self) { filter in
                                HStack {
                                    Text(filter)
                                    Spacer()
                                    Button(action: {
                                        toggleFilter(filter)
                                    }) {
                                        Image(systemName: selectedFilters.contains(filter) ? "checkmark.circle.fill" : "circle")
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                            
                            // Custom filter field
                            HStack {
                                TextField("Custom Filter", text: $customFilterName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(settings.font)
                                    .padding()
                                Button(action: {
                                    addCustomFilter()
                                }) {
                                    Text("Add Filter")
                                        .font(settings.font)
                                        .padding()
                                }
                                .disabled(customFilterName.isEmpty)
                            }
                        }
                    }
                    .frame(maxHeight: 200) // Limit the height of the filter list for scrolling
                }
            }
            
            Button(action: {
                settings.triggerHaptic()
                saveRecipe()
            }) {
                Text(isSaving ? "Saving..." : "Save Recipe")
                    .font(settings.font)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
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
        }
    }
    
    private func loadFilters() {
        allFilters = ["Vegan", "Italian", "Gluten-Free", "Vegetarian"]
    }
    
    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    private func addCustomFilter() {
        if !customFilterName.isEmpty {
            allFilters.append(customFilterName)
            customFilterName = ""
        }
    }
    
    private func saveRecipe() {
        guard let currentUser = DatabaseManager.shared.getCurrentUser() else {
            print("No user logged in")
            return
        }
        
        isSaving = true
        
        let success = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser.username,
            name: recipeName,
            description: recipeDescription,
            selectedFilters: Array(selectedFilters)
        )
        
        if success {
            print("Recipe saved successfully!")
            recipeName = ""
            recipeDescription = ""
            selectedFilters = []
        } else {
            print("Failed to save recipe")
            
        }
    }
}
