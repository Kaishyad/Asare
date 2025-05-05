import SwiftUI
import PhotosUI

struct CreateRecipePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipeName: String = ""
    @State private var recipeDescription: String = ""
    
    @State private var recipeNote: String = ""

    @State private var selectedFilters: Set<String> = []
    @State private var allFilters: [String] = []
    @State private var isSaving = false
    @State private var isFiltersExpanded: Bool = false
    @State private var customFilterName: String = ""

    @State private var currentUser: String = ""
    
    @State private var showSuccessBanner: Bool = false
    @State private var successMessage: String = ""
    @State private var showSuccessAlert = false

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
    @State private var navigateToRecipesView = false

    @State private var isTimeSectionExpanded: Bool = false
    
    @FocusState private var nameIsFocused: Bool
    @FocusState private var descIsFocused: Bool
    @FocusState private var urlIsFocused: Bool

    @State private var isMoreImagesExpanded = false
    @State private var selectedImages: [UIImage] = []
    @State private var completedIngredients: Set<String> = []

    @State private var isNavigatingToAddNoteView = false
    @State private var isRecipeNotesExpanded = false
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        NavigationLink(destination: RecipesView().environmentObject(settings), isActive: $navigateToRecipesView) { EmptyView() }
            NavigationView {
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        TextField("Recipe Name", text: $recipeName)
                            .font(settings.font)
                            .padding()
                            .frame(height: 50)
//                            .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color(uiColor: .systemBackground)) // background fills within corner radius
//                                )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(nameIsFocused ? Color.pink : Color(white: 0.8), lineWidth: 1)
                            )
                            .focused($nameIsFocused)
                            .accessibilityLabel("Recipe name field")


                        TextField("Description", text: $recipeDescription)
                            .font(settings.font)
                            .padding()
                            .frame(height: 100)
                            //.foregroundColor(.white)
//                            .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color(uiColor: .systemBackground))
//                                )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(descIsFocused ? Color.pink : Color(white: 0.8), lineWidth: 1)
                            )
                            .focused($descIsFocused) // Bind focus state to the TextField
                            .accessibilityLabel("Recipe description field")

                       
                       
                        // MARK: - Ingredient & Instruction Buttons
                       
                        VStack(spacing: 14) {
                            HStack(spacing: 20) {
                                let cappedFontSize = min(settings.fontSize, 25)
                                let dynamicWidth = max(170, cappedFontSize * 8)
                                
                                NavigationLink(destination: AddIngredientsView(ingredients: $ingredients).environmentObject(settings)) {
                                    VStack {
                                        Image(systemName: "carrot")
                                            .font(.system(size: 24))
                                        Text("Ingredients")
                                            .font(.system(size: cappedFontSize))
                                            .lineLimit(2)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 170, height: 100)
                                    .background(Color.pink)
                                    .cornerRadius(12)
                                }.accessibilityLabel("Add ingredients")
                                    .accessibilityAddTraits(.isButton)
                                
                                NavigationLink(destination: AddInstructionsView(instructions: $instructions).environmentObject(settings)) {
                                    VStack {
                                        Image(systemName: "book")
                                            .font(.system(size: 24))
                                        Text("Instructions")
                                            .font(.system(size: cappedFontSize))
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 170, height: 100)
                                    .background(Color.pink)
                                    .cornerRadius(12)
                                }
                                .accessibilityLabel("Add instructions")
                                   .accessibilityAddTraits(.isButton)
                            }

                            
                            
                            // MARK: - Ingredients Section
                            if !ingredients.isEmpty {
                                DesignCard {
                                    VStack(spacing: 14) {
                                        Button(action: {
                                            withAnimation { isIngredientsExpanded.toggle() }
                                        }) {
                                            HStack {
                                                Text("View Ingredients")
                                                    .font(settings.font)
                                                Spacer()
                                                Image(systemName: isIngredientsExpanded ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.pink)
                                            }
                                            .accessibilityLabel("View Ingredients")

                                        }

                                        if isIngredientsExpanded {
                                            VStack(spacing: 10) {
                                                ForEach(ingredients, id: \.name) { ingredient in
                                                    HStack(alignment: .top) {
                                                        Image(systemName: "circle.fill")
                                                            .font(.system(size: 8))
                                                            .foregroundColor(.pink)
                                                            .padding(.top, 6)

                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name)")
                                                                .font(settings.font)
                                                            if !ingredient.section.isEmpty {
                                                                Text("Section: \(ingredient.section)")
                                                                    .font(.footnote)
                                                                    .foregroundColor(.gray)
                                                            }
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding()
                                                    .background(Color(uiColor: .systemBackground))
                                                    .cornerRadius(10)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                                }
                                            }
                                            .transition(.slide)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }

                            // MARK: - Instructions Section
                            if !instructions.isEmpty {
                                DesignCard {
                                    VStack(spacing: 14) {
                                        Button(action: {
                                            withAnimation { isInstructionsExpanded.toggle() }
                                        }) {
                                            HStack {
                                                Text("View Instructions")
                                                    .font(settings.font)
                                                Spacer()
                                                Image(systemName: isInstructionsExpanded ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(.pink)
                                            }
                                        }

                                        if isInstructionsExpanded {
                                            VStack(spacing: 10) {
                                                ForEach(instructions, id: \.stepNumber) { instruction in
                                                    HStack(alignment: .top) {
                                                        Image(systemName: "checkmark.seal.fill")
                                                            .font(.system(size: 18))
                                                            .foregroundColor(.pink)
                                                            .padding(.top, 4)

                                                        VStack(alignment: .leading, spacing: 6) {
                                                            Text("Step \(instruction.stepNumber)")
                                                                .font(.headline)
                                                                .foregroundColor(.pink)
                                                            Text(instruction.instructionText)
                                                                .font(settings.font)
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding()
                                                    .background(Color(uiColor: .systemBackground))
                                                    .cornerRadius(10)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                                }
                                            }
                                            .transition(.slide)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }

                       

                        
                        
                        // MARK: - Filter Selection Section
                        DesignCard {
                            VStack(spacing: 14) {
                                Button(action: {
                                    withAnimation {
                                        isFiltersExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle.fill")
                                            .font(settings.font)
                                        Spacer()
                                        Image(systemName: isFiltersExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.pink)
                                    }
                                    .padding()
                                }

                                if !isFiltersExpanded && !selectedFilters.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(selectedFilters.sorted(), id: \.self) { filter in
                                                Text(filter)
                                                    .font(settings.font)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .foregroundColor(.pink)
                                                    .background(Color(uiColor: .systemBackground))
                                                    .cornerRadius(20)
                                                    .shadow(color: Color.pink.opacity(0.1), radius: 3, x: 0, y: 2)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }

                                if isFiltersExpanded {
                                    VStack(spacing: 10) {
                                        ScrollView(.vertical, showsIndicators: true) {
                                            VStack(spacing: 10) {
                                                ForEach(allFilters, id: \.self) { filter in
                                                    HStack {
                                                        Button(action: { toggleFilter(filter) }) {
                                                            Image(systemName: selectedFilters.contains(filter) ? "checkmark.circle.fill" : "circle")
                                                                .foregroundColor(selectedFilters.contains(filter) ? .pink : .gray)
                                                        }
                                                        Text(filter)
                                                            .font(settings.font)
                                                        Spacer()
                                                        Button(action: { deleteFilter(filter) }) {
                                                            Image(systemName: "trash")
                                                                .foregroundColor(.red)
                                                        }
                                                    }
                                                    .padding(.vertical, 5)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                        .frame(height: 150)

                                        Divider().padding(.vertical, 10)

                                        HStack {
                                            TextField("Enter custom filter", text: $customFilterName)
                                                .padding()
                                                .background(Color(uiColor: .secondarySystemBackground))
                                                .cornerRadius(12)
                                                .font(settings.font)


                                            Button(action: addCustomFilter) {
                                                Text("Add")
                                                    .fontWeight(.semibold)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 10)
                                                    .background(Color.pink)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(12)
                                            }
                                            .disabled(customFilterName.isEmpty || selectedFilters.contains(customFilterName) || allFilters.contains(customFilterName))
                                        }
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                        }


                        // MARK: - Time Selection Section
                        DesignCard {
                            VStack(spacing: 14) {
                                Button(action: {
                                    withAnimation {
                                        isTimeSectionExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("Time", systemImage: "clock")
                                            .font(settings.font)
                                        Spacer()
                                        Text("\(recipeHours) hr \(recipeMinutes) min")
                                            .font(settings.font)
                                            .fontWeight(.medium)
                                            .foregroundColor(.pink)
                                        Image(systemName: isTimeSectionExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.pink)
                                    }
                                    .padding()
                                }

                                if isTimeSectionExpanded {
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
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                        }
                        
                        // MARK: - Recipe Note Button
                        DesignCard {
                            VStack(spacing: 14) {
                                Button(action: {
                                    withAnimation {
                                        isRecipeNotesExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("Recipe Notes", systemImage: "text.bubble")
                                            .font(settings.font)
                                        Spacer()
                                        
                                        Spacer()
                                        Image(systemName: isRecipeNotesExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.pink)
                                    }
                                    .padding()
                                }

                                if isRecipeNotesExpanded {
                                    VStack(spacing: 12) {
                                        Text(recipeNote.isEmpty ? "Add a note..." : recipeNote)
                                            .font(settings.font)
                                            .foregroundColor(recipeNote.isEmpty ? Color.gray : Color.black)
                                            .padding()
                                            .background(Color(uiColor: .secondarySystemBackground))
                                            .cornerRadius(8)
                                            .frame(height: 80)
                                        
                                        NavigationLink(
                                            destination: AddNoteView(recipeNote: $recipeNote).environmentObject(settings),
                                            isActive: $isNavigatingToAddNoteView
                                        ) {
                                            Text("Edit Notes")
                                                .font(settings.font)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.pink)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        .padding(.top, 10)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                        }
                        
                        
                        
                        
                        // MARK: - Cover Image Section
                        DesignCard {
                            VStack(spacing: 14) {
                                Button(action: {
                                    withAnimation {
                                        isCoverImageExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("Cover Image", systemImage: "photo")
                                            .font(settings.font)
                                        Spacer()
                                        Image(systemName: isCoverImageExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.pink)
                                    }
                                    .padding()
                                }

                                if isCoverImageExpanded {
                                    VStack(spacing: 12) {
                                        if let coverImage {
                                            Image(uiImage: coverImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                                .cornerRadius(12)
                                        }
                                        
                                        PhotosPicker(selection: $selectedImageItem, matching: .images) {
                                            HStack {
                                                Image(systemName: "photo.fill")
                                                    .foregroundColor(.white)
                                                Text("Choose Image")
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.pink)
                                            .cornerRadius(12)
                                            .shadow(radius: 5)
                                        }
                                        .onChange(of: selectedImageItem) { loadImage(from: $0) }
                                        .accessibilityLabel("Choose cover image")
                                        .accessibilityAddTraits(.isButton)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                        }
                        
                        
                        // MARK: - Video URL Input
                        DesignCard {
                            VStack(spacing: 14) {
                                Button(action: {
                                    withAnimation { isURLSectionExpanded.toggle() }
                                }) {
                                    HStack {
                                        Label("Video / Website Link", systemImage: "video")
                                            .font(settings.font)
                                            //.fontWeight(.bold)
                                        Spacer()
                                        Image(systemName: isURLSectionExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.pink)
                                    }
                                }

                                if isURLSectionExpanded {
                                    TextField("https://example.com", text: Binding(
                                        get: { videoURL ?? "" },
                                        set: { videoURL = $0.isEmpty ? nil : $0 }
                                    ))
                                    .textInputAutocapitalization(.none)
                                    .keyboardType(.URL)
                                    .padding()
                                    .font(settings.font)
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(urlIsFocused ? Color.pink : Color.gray.opacity(0.4), lineWidth: 1)
                                    )
                                    .focused($urlIsFocused)
                                    .accessibilityLabel("Video or website URL input")

                                }
                            }
                            .padding(.vertical, 8)
                        }
                        



                        // MARK: - Add More Images Section
                        DesignCard {
                            VStack(spacing: 14) {
                                Button(action: {
                                    withAnimation {
                                        isMoreImagesExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("Add More Images", systemImage: "photo.on.rectangle.angled")
                                            .font(settings.font)
                                        Spacer()
                                        Image(systemName: isMoreImagesExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.pink)
                                    }
                                    .padding()
                                }

                                if isMoreImagesExpanded {
                                    VStack(spacing: 12) {
                                        PhotosPicker(
                                            selection: $selectedImageItems,
                                            maxSelectionCount: 5,
                                            matching: .images
                                        ) {
                                            HStack {
                                                Image(systemName: "photo.fill")
                                                Text("Choose Images")
                                                    .fontWeight(.semibold)
                                            }
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.pink)
                                            .cornerRadius(12)
                                            .shadow(radius: 5)
                                        }
                                        .onChange(of: selectedImageItems) { loadSelectedImages() }

                                        if !selectedImages.isEmpty {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 10) {
                                                    ForEach(selectedImages, id: \.self) { image in
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 80, height: 80)
                                                            .clipped()
                                                            .cornerRadius(10)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                            )
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                    .transition(.slide)
                                }
                            }
                        }


                        
                        Button(action: saveRecipe) {
                            Text(isSaving ? "Saving..." : "Save Recipe")
                                .padding()
                                .font(settings.font)
                                .frame(maxWidth: .infinity)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(isSaving || recipeName.isEmpty || recipeDescription.isEmpty || ingredients.isEmpty || instructions.isEmpty || (recipeHours == 0 && recipeMinutes == 0))
                        .accessibilityAddTraits(.isButton)

                    }
                    .padding()
                }
                
                .background(Color(uiColor: .secondarySystemBackground))
                .navigationTitle("Create New Recipe")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveRecipe()
                        }
                    }
                }
                .toolbarBackground(Color(uiColor: .secondarySystemBackground), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)

                .navigationBarBackButtonHidden(true)

                .onAppear {
                    if currentUser.isEmpty, let user = DatabaseManager.shared.getCurrentUser() {
                        currentUser = user.username
                    }

                    if allFilters.isEmpty {
                        loadFilters()
                    }
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
                                        .zIndex(1)
                                }
                                Spacer()
                            }
                        )
            }
            .alert("Missing Information", isPresented: $showValidationAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(validationMessage)
            })
        }
        
    
//MARK: - Save recipe
    private func saveRecipe() {
        guard !isSaving else { return }
        isSaving = true

        var missingFields: [String] = []

        if currentUser.isEmpty {
            missingFields.append("User not logged in")
        }

        if recipeName.isEmpty {
            print("Recipe name is empty")
            missingFields.append("Recipe name")
        }

        if recipeDescription.isEmpty {
            print("Recipe description is empty")
            missingFields.append("Description")
        }

        if ingredients.isEmpty {
            print("Ingredients are missing")
            missingFields.append("At least one ingredient")
        }

        if instructions.isEmpty {
            print("Instructions are missing")
            missingFields.append("At least one instruction")
        }

        if selectedFilters.isEmpty {
            print("No filters selected")
            missingFields.append("At least one filter")
        }

        let totalTimeInMinutes = (recipeHours * 60) + recipeMinutes
        if totalTimeInMinutes == 0 {
            print("Invalid time input: \(recipeHours) hr \(recipeMinutes) min")
            missingFields.append("Cooking time")
        }

        if coverImage == nil {
            print("Cover image is missing")
            missingFields.append("Cover image")
        }

        if recipeNote.isEmpty {
            print("Recipe note is missing")
            missingFields.append("Recipe note")
        }

        if let videoURL = videoURL, !isValidURL(videoURL) {
            print("Invalid video URL")
            missingFields.append("Valid video URL")
        }

        otherImages = []
        for image in selectedImages {
            if let fullPath = saveImageToDocuments(image: image) {
                print("Saved image to: \(fullPath)")
                otherImages.append(fullPath)
            } else {
                print("Failed to save image.")
            }
        }


        if !missingFields.isEmpty {
            validationMessage = "Please fill in the following:\n• " + missingFields.joined(separator: "\n• ")
            showValidationAlert = true
            isSaving = false
            return
        }

        let success = RecipeDatabaseManager.shared.addRecipe(
            username: currentUser,
            name: recipeName,
            description: recipeDescription,
            time: totalTimeInMinutes,
            selectedFilters: Array(selectedFilters),
            ingredients: ingredients,
            instructions: instructions,
            coverImagePath: coverImagePath,
            otherImages: otherImages,
            videoURL: videoURL,
            note: recipeNote
        )

        if success {
            showSuccessBanner = true
            successMessage = "Recipe saved successfully!"

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccessBanner = false
            }

            resetFormFields()
        } else {
            print("Failed to save the recipe. Please try again.")
        }

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
        coverImage = nil
        coverImagePath = nil
        otherImages.removeAll()
        selectedImageItems.removeAll()
        selectedImageItem = nil
        videoURL = nil
        recipeNote = ""
    }






//MARK: - Helper functions
    func loadSelectedImages() {
        selectedImages = []

        for item in selectedImageItems {
            Task {
                do {
                    if let imageData = try await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: imageData) {
                        await MainActor.run {
                            selectedImages.append(image)
                        }
                    } else {
                        print("Failed to load image data from PhotosPickerItem.")
                    }
                } catch {
                    print("Error loading image: \(error)")
                }
            }
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
                DispatchQueue.main.async {
                    coverImage = uiImage
                    coverImagePath = saveImageToDocuments(image: uiImage)
                }
            } else {
                print("Failed to load image data")
            }
        }
    }




    private func saveImageToDocuments(image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: url)
                return url.path
            } catch {
                print("Failed to write image: \(error)")
            }
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


struct DesignCard<Content: View>: View {
    var content: () -> Content

    var body: some View {
        VStack {
            content()
        }
        .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
}
