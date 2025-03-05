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

    @State private var ingredients: [(name: String, amount: String, measurement: String)] = []
    @State private var instructions: [(stepNumber: Int, instructionText: String)] = []
    
    @State private var videoURL: String = ""
    @State private var isURLSectionExpanded = false


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
                
                TextField("Enter Recipe Name", text: $recipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(settings.font)
                    .padding()
                
                TextField("Enter Recipe Description", text: $recipeDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(settings.font)
                    .padding()
                
                Section {
                    DisclosureGroup("Add YouTube/Website URL", isExpanded: $isURLSectionExpanded) {
                        TextField("Enter URL", text: $videoURL)
                            .textInputAutocapitalization(.none)
                            .keyboardType(.URL)
                            .padding()
                    }
                

                }

                
                // Ingredients Section
                VStack(alignment: .leading) {
                    Button(action: { isIngredientsExpanded.toggle() }) {
                        HStack {
                            Text("Ingredients")
                                .font(settings.font)
                                .foregroundColor(.pink)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: isIngredientsExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.top)
                    }
                    
                    if isIngredientsExpanded {
                        VStack(alignment: .leading) {
                            // Add Ingredient button
                            NavigationLink(destination: AddIngredientsView(ingredients: $ingredients)) {
                                Text("Add Ingredient")
                                    .font(settings.font)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.pink.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.bottom, 5)
                            }
                            
                            // Display list of added ingredients
                            if ingredients.isEmpty {
                                Text("No ingredients added yet.")
                                    .foregroundColor(.gray)
                                    .padding(.top)
                            } else {
                                List(ingredients, id: \.name) { ingredient in
                                    Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name)")
                                }
                                .frame(maxHeight: 150)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                
                //MARK: - Instructions Section
                VStack(alignment: .leading) {
                    Button(action: { isInstructionsExpanded.toggle() }) {
                        HStack {
                            Text("Instructions")
                                .font(settings.font)
                                .foregroundColor(.pink)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: isInstructionsExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.top)
                    }
                    
                    if isInstructionsExpanded {
                        VStack(alignment: .leading) {
                            // Add Instruction button
                            NavigationLink(destination: AddInstructionsView(instructions: $instructions)) {
                                Text("Add Instruction")
                                    .font(settings.font)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.pink.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.bottom, 5)
                            }
                            
                            // Display list of added instructions
                            if instructions.isEmpty {
                                Text("No instructions added yet.")
                                    .foregroundColor(.gray)
                                    .padding(.top)
                            } else {
                                List(instructions, id: \.stepNumber) { instruction in
                                    Text("Step \(instruction.stepNumber): \(instruction.instructionText)")
                                }
                                .frame(maxHeight: 150)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                


                
                //MARK: - Filters Section
                VStack(alignment: .leading) {
                    Button(action: { isFiltersExpanded.toggle() }) {
                        HStack {
                            Text("Filters: \(selectedFilters.isEmpty ? "None" : selectedFilters.joined(separator: ", "))")
                                .font(settings.font)
                                .foregroundColor(.pink)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: isFiltersExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.top)
                    }
                    
                    if isFiltersExpanded {
                        ScrollView {
                            VStack(alignment: .leading) {
                                // Existing filters display
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
                                
                                // Custom filter input
                                HStack {
                                    TextField("Enter custom filter", text: $customFilterName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.top)
                                    
                                    Button(action: addCustomFilter) {
                                        Text("Add")
                                            .font(settings.font)
                                            .padding()
                                            .background(Color.pink)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.leading)
                                    .disabled(customFilterName.isEmpty || selectedFilters.contains(customFilterName) || allFilters.contains(customFilterName)) // Disable if invalid
                                }
                                .padding(.top)
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
            
                
                //MARK: - Cover Image Section
                VStack(alignment: .leading) {
                    // Header
                    Button(action: { isCoverImageExpanded.toggle() }) {
                        HStack {
                            Text("Cover Image")
                                .font(settings.font)
                                .foregroundColor(.pink)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: isCoverImageExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.top)
                    }

                    // Expanded Section
                    if isCoverImageExpanded {
                        VStack {
                            // Show selected image or placeholder
                            if let coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            } else {
                                Text("Select a Cover Image")
                                    .foregroundColor(.gray)
                            }

                            // Select Image Button
                            PhotosPicker(selection: $selectedImageItem, matching: .images) {
                                Text("Choose Image")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .onChange(of: selectedImageItem) { newItem in
                                loadImage(from: newItem)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }


                // MARK: - Time picker section
                VStack(alignment: .leading) {
                    Button(action: { isTimeExpanded.toggle() }) {
                        HStack {
                            Text("Time")
                                .font(settings.font)
                                .foregroundColor(.pink)
                            Spacer()
                            Text("\(recipeHours) hr \(recipeMinutes) min")
                                .font(settings.font)
                                .foregroundColor(.pink)
                            Image(systemName: isTimeExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.top)
                    }

                    if isTimeExpanded {
                        HStack {
                            VStack {
                                Text("Hours")
                                    .font(.subheadline)
                                Picker("Hours", selection: $recipeHours) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        Text("\(hour) hr").tag(hour)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(maxWidth: .infinity)
                            }

                            VStack {
                                Text("Minutes")
                                    .font(.subheadline)
                                Picker("Minutes", selection: $recipeMinutes) {
                                    ForEach(0..<60, id: \.self) { minute in
                                        Text("\(minute) min").tag(minute)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()

                    }
                    
                }
                VStack(alignment: .leading) {
                    //MARK: - all images
                    PhotosPicker(selection: $selectedImageItems, maxSelectionCount: 5, matching: .images) {
                        Text("Add Images")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedImageItems) { newItems in
                        loadSelectedImages()
                    }
                }
                VStack(alignment: .leading) {
                    
                    Button(action: saveRecipe) {
                        Text(isSaving ? "Saving..." : "Save Recipe")
                            .font(settings.font)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isSaving || recipeName.isEmpty || recipeDescription.isEmpty || ingredients.isEmpty || instructions.isEmpty || (recipeHours == 0 && recipeMinutes == 0))
                    
                    Spacer()
                    
                }
            }
            .navigationTitle("Create New Recipe")
            .padding()
            .onAppear {
                loadFilters()
                if let currentUser = DatabaseManager.shared.getCurrentUser() {
                    self.currentUser = currentUser.username
                }
            }
        }
    }
    
//MARK: - Save recipe
    private func saveRecipe() {
        guard !currentUser.isEmpty else {
            print("No user logged in")
            return
        }

        guard let time = Int(recipeTime), time > 0 else {
            print("Invalid time input")
            return
        }

        isSaving = true

        let success = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser,
            name: recipeName,
            description: recipeDescription,
            time: time,
            selectedFilters: Array(selectedFilters),
            ingredients: ingredients,
            instructions: instructions,
            coverImagePath: coverImagePath,
            otherImages: otherImages,
            videoURL: videoURL.isEmpty ? nil : videoURL

        )

        if success {
            showSuccessBanner = true
            successMessage = "Recipe saved successfully!"

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccessBanner = false
            }

            recipeName = ""
            recipeDescription = ""
            selectedFilters.removeAll()
            recipeTime = ""
            ingredients.removeAll()
            otherImages.removeAll()
        } else {
            print("Failed to save recipe")
        }

        isSaving = false
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
            otherImages.append(contentsOf: newImagePaths) // Now appending paths instead of UIImage
        }
    }

    func saveImageToDocumentsDirectory(image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: path)
            return path.path
        }
        return nil
    }


    private func loadImage(from item: PhotosPickerItem?) {
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    coverImage = uiImage
                    coverImagePath = saveImageToDocuments(image: uiImage)
                }
            }
        }

        // Save image to the app's documents folder
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
