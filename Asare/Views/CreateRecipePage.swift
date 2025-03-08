import SwiftUI
import PhotosUI

struct CreateRecipePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipeName: String = ""
    @State private var recipeDescription: String = ""
    
    @State private var selectedFilters: Set<String> = []
    @State private var allFilters: [String] = []
    @State private var isSaving = false
    @State private var isFiltersExpanded: Bool = false
    @State private var customFilterName: String = ""

    @State private var currentUser: String = ""
    
    @State private var showSuccessBanner: Bool = false
    @State private var successMessage: String = ""
    
    @State private var recipeTime: String = ""
    @State private var recipeHours: Int = 0
    @State private var recipeMinutes: Int = 0
    @State private var isTimeExpanded: Bool = false
    
    @State private var isIngredientsExpanded = false
    @State private var isInstructionsExpanded = false
    
    @State private var coverImage: UIImage?
    @State private var coverImagePath: String?
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var isCoverImageExpanded = false
    
    @State private var otherImages: [String] = []
    @State private var selectedImageItems: [PhotosPickerItem] = []

    @State private var ingredients: [(name: String, amount: String, measurement: String, section: String)] = []
    @State private var instructions: [(stepNumber: Int, instructionText: String)] = []
    
    @State private var videoURL: String? = nil
    @State private var isURLSectionExpanded = false
    
    @State private var isFavorite: Bool = false

    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        TextField("Enter Recipe Name", text: $recipeName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(settings.font)
                            .padding()
                        
                        TextField("Enter Recipe Description", text: $recipeDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(settings.font)
                            .padding()
                        
                        TextField("Add YouTube/Website URL", text: Binding(
                            get: { videoURL ?? "" },
                            set: { videoURL = $0.isEmpty ? nil : $0 }
                        ))
                        .textInputAutocapitalization(.none)
                        .keyboardType(.URL)
                        .padding()

                            
                        
                        Text("Ingredients")
                            .font(settings.font)
                            .fontWeight(.bold)
                        
                        NavigationLink(destination: AddIngredientsView(ingredients: $ingredients)) {
                            Text("Add Ingredient")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        ForEach(ingredients, id: \ .name) { ingredient in
                            Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name) \(ingredient.section) ")
                        }
                        
                        Text("Instructions")
                            .font(settings.font)
                            .fontWeight(.bold)
                        
                        NavigationLink(destination: AddInstructionsView(instructions: $instructions)) {
                            Text("Add Instruction")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        ForEach(instructions, id: \ .stepNumber) { instruction in
                            Text("Step \(instruction.stepNumber): \(instruction.instructionText)")
                        }
                        
                        Text("Filters")
                            .font(settings.font)
                            .fontWeight(.bold)
                        
                        ForEach(allFilters, id: \ .self) { filter in
                            HStack {
                                Button(action: { toggleFilter(filter) }) {
                                    Image(systemName: selectedFilters.contains(filter) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedFilters.contains(filter) ? .pink : .gray)
                                }
                                Text(filter)
                                Spacer()
                                Button(action: { deleteFilter(filter) }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                            }
                        }
                        
                        TextField("Enter custom filter", text: $customFilterName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: addCustomFilter) {
                            Text("Add")
                                .padding()
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Text("Cover Image")
                            .font(settings.font)
                            .fontWeight(.bold)
                        
                        if let coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        }
                        
                        PhotosPicker(selection: $selectedImageItem, matching: .images) {
                            Text("Choose Image")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .onChange(of: selectedImageItem) { loadImage(from: $0) }
                        
                        Text("Time: \(recipeHours) hr \(recipeMinutes) min")
                            .font(settings.font)
                        
                        HStack {
                            Picker("Hours", selection: $recipeHours) {
                                ForEach(0..<24) { Text("\($0) hr").tag($0) }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            
                            Picker("Minutes", selection: $recipeMinutes) {
                                ForEach(0..<60) { Text("\($0) min").tag($0) }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                        }
                        
                        PhotosPicker(selection: $selectedImageItems, maxSelectionCount: 5, matching: .images) {
                            Text("Add Images")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .onChange(of: selectedImageItems) { loadSelectedImages() }
                        
                        Button(action: saveRecipe) {
                            Text(isSaving ? "Saving..." : "Save Recipe")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(isSaving || recipeName.isEmpty || recipeDescription.isEmpty || ingredients.isEmpty || instructions.isEmpty || (recipeHours == 0 && recipeMinutes == 0))
                    }
                    .padding()
                }
                .navigationTitle("Create New Recipe")
                .onAppear {
                        if let user = DatabaseManager.shared.getCurrentUser() {
                            currentUser = user.username
                            print("Current user: \(currentUser)")
                        } else {
                            print("No user logged in")
                        }
                    loadFilters()
                }
                .overlay(
                            VStack {
                                if showSuccessBanner {
                                    Text(successMessage)
                                        .font(settings.font)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .transition(.move(edge: .top))
                                        .zIndex(1) // Ensure it stays on top
                                }
                                Spacer()
                            }
                        )
            }
        }
    
//MARK: - Save recipe
    private func saveRecipe() {
        // Prevent saving if already in progress
        guard !isSaving else {
            return
        }

        // Set saving state to true
        isSaving = true
        
        // Validation checks
        guard !currentUser.isEmpty else {
            print("No user logged in")
            isSaving = false
            return
        }

        // Calculate the total time in minutes
        let totalTimeInMinutes = (recipeHours * 60) + recipeMinutes
        guard totalTimeInMinutes > 0 else {
            print("Invalid time input: \(recipeHours) hours and \(recipeMinutes) minutes are not valid.")
            isSaving = false
            return
        }

        guard !recipeName.isEmpty else {
            print("Recipe name is empty")
            isSaving = false
            return
        }

        guard !recipeDescription.isEmpty else {
            print("Recipe description is empty")
            isSaving = false
            return
        }

        guard !ingredients.isEmpty else {
            print("Ingredients are missing")
            isSaving = false
            return
        }

        guard !instructions.isEmpty else {
            print("Instructions are missing")
            isSaving = false
            return
        }

        guard !selectedFilters.isEmpty else {
            print("No filters selected")
            isSaving = false
            return
        }

        guard coverImage != nil else {
            print("Cover image is missing")
            isSaving = false
            return
        }

        if let videoURL = videoURL, !isValidURL(videoURL) {
                print("Invalid video URL: \(videoURL)")
                isSaving = false
                return
            }
        
        // If all validation passes, proceed with saving the recipe
        let success = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser,
            name: recipeName,
            description: recipeDescription,
            time: totalTimeInMinutes, // Use computed minutes instead of recipeTime
            selectedFilters: Array(selectedFilters),
            ingredients: ingredients,
            instructions: instructions,
            coverImagePath: coverImagePath, // Ensure this is correctly stored
            otherImages: otherImages,
            videoURL: videoURL
        )

        if success {
            showSuccessBanner = true
            successMessage = "Recipe saved successfully!"

            // Hide the success banner after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccessBanner = false
            }

            resetFormFields()
        } else {
            print("Failed to save the recipe. Please try again.")
        }

        // Reset saving state
        isSaving = false
    }


    private func isValidURL(_ url: String) -> Bool {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }

    private func resetFormFields() {
        recipeName = ""
        recipeDescription = ""
        selectedFilters.removeAll()
        recipeHours = 0
        recipeMinutes = 0
        ingredients.removeAll()
        instructions.removeAll()
        coverImagePath = nil
        otherImages.removeAll()
    }





//MARK: - Helper functions
    func loadSelectedImages() {
        Task {
            var newImagePaths: [String] = []
            for item in selectedImageItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let imagePath = saveImageToDocumentsDirectory(image: image) { // Convert UIImage to file path
                    newImagePaths.append(imagePath)
                }
            }
            otherImages.append(contentsOf: newImagePaths)
        }
    }

    func saveImageToDocumentsDirectory(image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: path)
                return path.path
            } catch {
                print("Error saving image to documents directory: \(error)")
                return nil
            }
        }
        return nil
    }



    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                coverImage = uiImage
                coverImagePath = saveImageToDocuments(image: uiImage)
            } else {
                print("Failed to load image data")
            }
        }
    }



        private func saveImageToDocuments(image: UIImage) -> String? {
            let filename = UUID().uuidString + ".jpg"
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: path)
                return path.path
            }
            return nil
        }
    private func loadFilters() {
        allFilters = FilterManager.shared.getAllFilters()
    }

    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }

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
    private func addCustomFilter() {
            guard !customFilterName.isEmpty && !selectedFilters.contains(customFilterName) && !allFilters.contains(customFilterName) else {
                print("Invalid custom filter")
                return
            }

            selectedFilters.insert(customFilterName)
            allFilters.append(customFilterName)
            customFilterName = "" // Clear the custom filter input field
        }
}
