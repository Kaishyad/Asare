import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    var recipe: (id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?, note: String?)

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: AppSettings
    @Binding var refreshTrigger: UUID

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var videoURL: String = ""
    @State private var recipeNote: String = ""
    @State private var recipeHours: Int = 0
    @State private var recipeMinutes: Int = 0
    @State private var selectedFilters: Set<String> = []
    @State private var allFilters: [String] = []

    @State private var ingredients: [(name: String, amount: String, measurement: String, section: String)] = []
    @State private var instructions: [(stepNumber: Int, instructionText: String)] = []

    @State private var coverImagePath: String?
    @State private var coverImage: UIImage?
    @State private var otherImagePaths: [String] = []
    @State private var selectedCoverImageItem: PhotosPickerItem?
    @State private var selectedOtherImageItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    @State private var isSaving = false
    @State private var showSaveConfirmation = false

    @State private var isDetailsExpanded = false
    @State private var isInstructionsExpanded = false
    @State private var isIngredientsExpanded = false
    @State private var isNoteExpanded = false
    @State private var isFiltersExpanded = false
    @State private var isTimeExpanded = false
    @State private var isURLSectionExpanded = false
    @State private var isCoverImageExpanded = false
    @State private var isOtherImagesExpanded = false

    @FocusState private var nameIsFocused: Bool
    @FocusState private var descIsFocused: Bool
    @FocusState private var urlIsFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                collapsibleCard(isExpanded: $isDetailsExpanded, title: "Recipe Details", icon: "doc.text") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Name").font(settings.headlineFont)
                        TextField("Enter recipe name", text: $name)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(8)
                            .font(settings.font)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                        Text("Description").font(settings.headlineFont)
                        TextEditor(text: $description)
                            .frame(minHeight: 150)
                            .padding(4)
                            .font(settings.font)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                }

                collapsibleCard(isExpanded: $isIngredientsExpanded, title: "Ingredients", icon: "carrot") {
                    AddIngredientsView(ingredients: $ingredients).environmentObject(settings)
                    if ingredients.isEmpty {
                        Text("No ingredients added yet.")
                            .foregroundColor(.gray)
                            .font(settings.subheadlineFont)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(groupedIngredients.keys.sorted(), id: \.self) { section in
                                Text(section).font(settings.headlineFont).foregroundColor(.pink)
                                ForEach(groupedIngredients[section] ?? [], id: \.name) { ingredient in
                                    HStack {
                                        Text("\(ingredient.amount) \(ingredient.measurement) of \(ingredient.name)")
                                            .font(settings.font)
                                        Spacer()
                                        Button(action: { deleteIngredient(ingredient) }) {
                                            Image(systemName: "trash.fill").foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                Divider()
                            }
                        }.padding(.vertical, 5)
                    }
                }

                collapsibleCard(isExpanded: $isInstructionsExpanded, title: "Instructions", icon: "book") {
                    AddInstructionsView(instructions: $instructions).environmentObject(settings)
                }

                collapsibleCard(isExpanded: $isNoteExpanded, title: "Recipe Notes", icon: "text.bubble") {
                    TextEditor(text: $recipeNote)
                        .font(settings.font)
                        .padding()
                        .frame(minHeight: 200)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }

                collapsibleCard(isExpanded: $isFiltersExpanded, title: "Filters", icon: "line.3.horizontal.decrease.circle.fill") {
                    VStack(alignment: .leading) {
                        ForEach(allFilters, id: \.self) { filter in
                            HStack {
                                Button(action: { toggleFilter(filter) }) {
                                    Image(systemName: selectedFilters.contains(filter) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedFilters.contains(filter) ? .pink : .gray)
                                }
                                Text(filter).font(settings.font)
                                Spacer()
                            }
                        }
                    }
                }

                collapsibleCard(isExpanded: $isTimeExpanded, title: "Time", icon: "clock") {
                    HStack {
                        Picker("Hours", selection: $recipeHours) {
                            ForEach(0..<24) { Text("\($0) hr") }
                        }
                        Picker("Minutes", selection: $recipeMinutes) {
                            ForEach(0..<60) { Text("\($0) min") }
                        }
                    }
                }

                collapsibleCard(isExpanded: $isURLSectionExpanded, title: "Video / Website Link", icon: "video") {
                    TextField("https://example.com", text: $videoURL)
                        .textInputAutocapitalization(.none)
                        .keyboardType(.URL)
                        .padding()
                        .font(settings.font)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(urlIsFocused ? Color.pink : Color.gray.opacity(0.4), lineWidth: 1))
                        .focused($urlIsFocused)
                }

                collapsibleCard(isExpanded: $isCoverImageExpanded, title: "Cover Image", icon: "photo") {
                    VStack(spacing: 12) {
                        if let coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        }
                        PhotosPicker(selection: $selectedCoverImageItem, matching: .images) {
                            Label("Choose Cover Image", systemImage: "photo.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.pink)
                                .cornerRadius(12)
                        }
                        .onChange(of: selectedCoverImageItem) { loadCoverImage(from: $0) }
                    }
                }

                collapsibleCard(isExpanded: $isOtherImagesExpanded, title: "Add More Images", icon: "photo.on.rectangle.angled") {
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedOtherImageItems, maxSelectionCount: 5, matching: .images) {
                            Label("Choose Images", systemImage: "photo.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.pink)
                                .cornerRadius(12)
                        }
                        .onChange(of: selectedOtherImageItems) { loadOtherImages() }

                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(selectedImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }
                }

//                Button(action: saveChanges) {
//                    Text("Save Changes")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.pink)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .font(settings.font)
//                }
//                .disabled(isSaving)
            }
            .padding()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .navigationTitle("Editing \(recipe.name)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .foregroundStyle(Color.pink)
            }
        }
        .toolbarBackground(Color(uiColor: .secondarySystemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        .onAppear(perform: loadData)
        .alert(isPresented: $showSaveConfirmation) {
            Alert(title: Text("Recipe Updated"), message: Text("Changes saved."), dismissButton: .default(Text("OK")) {
                refreshTrigger = UUID()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
//Code adapted from Code with Franck, 2024
    private func collapsibleCard<Content: View>(isExpanded: Binding<Bool>, title: String, icon: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            content().padding(.top, 5)
                .foregroundColor(.pink)

        } label: {
            Label(title, systemImage: icon)
                .font(settings.headlineFont)
        }
        .foregroundStyle(Color.pink)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
//End of adaption

    private func loadData() {
        name = recipe.name
        description = recipe.description
        videoURL = recipe.videoURL ?? ""
        recipeNote = recipe.note ?? ""
        recipeHours = recipe.time / 60
        recipeMinutes = recipe.time % 60
        selectedFilters = Set(recipe.filters)
        allFilters = FilterManager.shared.getAllFilters()
        if let path = RecipeDatabaseManager.shared.getCoverImage(forRecipeId: recipe.id) {
            coverImagePath = path
            coverImage = UIImage(contentsOfFile: path)
        }
        otherImagePaths = RecipeDatabaseManager.shared.getOtherImages(forRecipeId: recipe.id)
        instructions = InstructionsManager.shared.fetchInstructions(recipeId: recipe.id)
        ingredients = IngredientManager.shared.fetchIngredientsForRecipe(recipeId: recipe.id)
    }

    private func saveChanges() {
        isSaving = true

        let totalTime = (recipeHours * 60) + recipeMinutes
        let success = RecipeDatabaseManager.shared.updateRecipeBasicDetails(
            id: recipe.id,
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            videoURL: videoURL.isEmpty ? nil : videoURL
        )

        if success {
            InstructionsManager.shared.addInstructions(recipeId: recipe.id, instructionsList: instructions)
            IngredientManager.shared.replaceIngredients(for: recipe.id, with: ingredients)

            RecipeDatabaseManager.shared.updateRecipeNote(recipeId: recipe.id, note: recipeNote)
            RecipeDatabaseManager.shared.updateRecipeFilters(recipeId: recipe.id, filters: Array(selectedFilters))
            RecipeDatabaseManager.shared.updateRecipeTime(recipeId: recipe.id, time: totalTime)

            showSaveConfirmation = true
        }

        isSaving = false
    }


    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }

    private func loadCoverImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    coverImage = uiImage
                    coverImagePath = saveImageToDocuments(image: uiImage)
                }
            }
        }
    }

    private func loadOtherImages() {
        Task {
            var newImagePaths: [String] = []
            for item in selectedOtherImageItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let imagePath = saveImageToDocuments(image: image) {
                    newImagePaths.append(imagePath)
                    selectedImages.append(image)
                }
            }
            otherImagePaths.append(contentsOf: newImagePaths)
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

    private var groupedIngredients: [String: [(name: String, amount: String, measurement: String, section: String)]] {
        Dictionary(grouping: ingredients, by: { $0.section })
    }

    private func deleteIngredient(_ ingredient: (name: String, amount: String, measurement: String, section: String)) {
        if let index = ingredients.firstIndex(where: {
            $0.name == ingredient.name &&
            $0.amount == ingredient.amount &&
            $0.measurement == ingredient.measurement &&
            $0.section == ingredient.section
        }) {
            ingredients.remove(at: index)
        }
    }
    
    
}
