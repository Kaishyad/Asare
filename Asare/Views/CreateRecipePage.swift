import SwiftUI

struct CreateRecipePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipeName: String = ""
    @State private var recipeDescription: String = ""
    @State private var selectedFilters: Set<String> = [] // Selected filters are stored in a Set for uniqueness
    @State private var customFilterName: String = "" // Custom filter input field
    @State private var allFilters: [String] = [] // List of all available filters
    @State private var isSaving = false
    @State private var isFiltersExpanded: Bool = false
    @State private var currentUser: String = ""
    @State private var showSuccessBanner: Bool = false // Variable to control the banner visibility
    @State private var successMessage: String = "" // Success message to display
    @State private var recipeTime: String = "" // Time input as a string
    @State private var isIngredientsExpanded = false

    // Ingredients state variables
    @State private var ingredients: [(name: String, amount: String, measurement: String)] = []

    var body: some View {
        NavigationView {
            VStack {
                // Success Banner
                if showSuccessBanner {
                    Text(successMessage)
                        .font(settings.font)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: showSuccessBanner)
                }

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

                // Ingredients Section
                VStack(alignment: .leading) {
                    NavigationLink(destination: AddIngredientsView(ingredients: $ingredients)) {
                        Text("Add Ingredients")
                            .font(.body)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // Display list of added ingredients
                    List(ingredients, id: \.name) { ingredient in
                        Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name)")
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
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }

                VStack {
                    TextField("Enter Time (in minutes)", text: $recipeTime)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(settings.font)
                        .padding()

                    Button(action: saveRecipe) {
                        Text(isSaving ? "Saving..." : "Save Recipe")
                            .font(settings.font)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isSaving || recipeName.isEmpty || recipeDescription.isEmpty || recipeTime.isEmpty || ingredients.isEmpty) // Disable if any field is empty

                    Spacer()
                }
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
    }

    // Save the recipe with the selected filters and ingredients
    private func saveRecipe() {
        guard !currentUser.isEmpty else {
            print("No user logged in")
            return
        }

        // Ensure the recipe time is a valid integer
        guard let time = Int(recipeTime), time > 0 else {
            print("Invalid time input")
            return
        }

        isSaving = true

        let success = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser,
            name: recipeName,
            description: recipeDescription,
            time: time, // Pass the time value
            selectedFilters: Array(selectedFilters), // Convert Set to Array for saving
            ingredients: ingredients // Pass the ingredients list with amount
        )

        if success {
            showSuccessBanner = true
            successMessage = "Recipe saved successfully!"
            
            // Hide banner after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccessBanner = false
            }

            // Reset form fields
            recipeName = ""
            recipeDescription = ""
            selectedFilters.removeAll()
            recipeTime = "" // Reset the time field
            ingredients.removeAll() // Clear the ingredients list
        } else {
            print("Failed to save recipe")
        }

        isSaving = false
    }

    // Load all available filters
    private func loadFilters() {
        allFilters = FilterManager.shared.getAllFilters()
    }

    // Toggle the selection of a filter
    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }

    // Delete a selected filter
    private func deleteFilter(_ filter: String) {
        let success = FilterManager.shared.deleteFilter(name: filter)
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
