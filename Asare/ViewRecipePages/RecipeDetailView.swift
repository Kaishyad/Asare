import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var settings: AppSettings

    @State var recipe: (id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?, note: String?)

    @State private var coverImagePath: String?
    @State private var otherImagePaths: [String] = []
    @State private var instructions: [(stepNumber: Int, instructionText: String)] = []
    @State private var ingredientsBySection: [String: [(name: String, amount: String, measurement: String)]] = [:]
    @State private var showDeletionConfirmation: Bool = false
    @State private var selectedTab: Tab = .ingredients
    @State private var showCookMode: Bool = false
    @State private var showEditView: Bool = false
    @State private var isFavorite: Bool = false
    private let currentUser = DatabaseManager.shared.getCurrentUser()
    @State private var refreshID = UUID()

    @Environment(\.presentationMode) var presentationMode

    enum Tab: String, CaseIterable, Identifiable {
        case ingredients = "Ingredients"
        case instructions = "Instructions"
        case notes = "Notes"

        var id: String { self.rawValue }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text(recipe.description)
                        .font(settings.font)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .accessibilityAddTraits(.isHeader)

                    //Code adapted from Ng, 2023

                    let loadedImages: [UIImage] = ([coverImagePath] + otherImagePaths)
                        .compactMap { path in
                            guard let path = path,
                                  !path.trimmingCharacters(in: .whitespaces).isEmpty,
                                  FileManager.default.fileExists(atPath: path),
                                  let image = UIImage(contentsOfFile: path)
                            else {
                                return nil
                            }
                            return image
                        }

                    if !loadedImages.isEmpty {
                        TabView {
                            ForEach(loadedImages.indices, id: \.self) { index in
                                Image(uiImage: loadedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding([.horizontal, .bottom])
                    }
                    //End of Adaption

                    HStack(spacing: 30) {
                        Text(formatTime(minutes: recipe.time))
                            .font(settings.headlineFont)
                            .foregroundColor(.pink)
                            .padding(.horizontal)


                        NavigationLink(destination: EditRecipeView(recipe: recipe, refreshTrigger: $refreshID)) {
                            VStack {
                                Image(systemName: "pencil.circle.fill").font(.title2)
                                Text("Edit").font(settings.icons)
                            }.foregroundColor(.blue)
                        }                .accessibilityAddTraits(.isButton)


                        NavigationLink(destination: CookModeView(recipeId: recipe.id)) {
                            VStack {
                                Image(systemName: "play.circle.fill").font(.title2)
                                Text("Cook").font(settings.icons)
                            }.foregroundColor(.purple)
                        }                .accessibilityAddTraits(.isButton)


                        if let user = currentUser {
                            Button(action: {
                                if isFavorite {
                                    RecipeDatabaseManager.shared.removeFavorite(username: user.username, recipeId: recipe.id)
                                } else {
                                    RecipeDatabaseManager.shared.addFavorite(username: user.username, recipeId: recipe.id)
                                }
                                isFavorite.toggle()
                            }) {
                                VStack {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart").font(.title2)
                                    Text(isFavorite ? "Favorite" : "Favorite").font(settings.icons)
                                }.foregroundColor(isFavorite ? .pink : .gray)
                            }                .accessibilityAddTraits(.isButton)

                        }
                        
                        Button(action: deleteRecipe) {
                            VStack {
                                Image(systemName: "trash.fill").font(.title2)
                                Text("Delete").font(settings.icons)
                            }.foregroundColor(.red)
                        }                .accessibilityAddTraits(.isButton)

                    }
                    .padding(.horizontal)

                    if !recipe.filters.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(recipe.filters.sorted(), id: \.self) { filter in
                                    Text(filter)
                                        .font(settings.pickbar)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.pink)
                                        .background(settings.isDarkMode ? Color(uiColor: .secondarySystemBackground) : Color.white)
                                        .cornerRadius(20)
                                        .shadow(color: Color.pink.opacity(0.1), radius: 3)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    if let videoURL = recipe.videoURL, !videoURL.isEmpty {
                        Text(videoURL)
                            .font(settings.subheadlineFont)
                            .foregroundColor(.pink)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 16) {
                        Picker("Select", selection: $selectedTab) {
                            ForEach(Tab.allCases) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            switch selectedTab {
                            case .ingredients:
                                if !ingredientsBySection.isEmpty {
                                    ForEach(ingredientsBySection.keys.sorted(), id: \.self) { section in
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(section)
                                                .font(settings.headlineFont)
                                                .foregroundColor(.pink)
                                                .padding(.horizontal)
                                            ForEach(ingredientsBySection[section]!, id: \.name) { ingredient in
                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text(ingredient.name)
                                                            .font(settings.font)
                                                            .foregroundColor(settings.isDarkMode ?  Color.white : Color.black)
                                                        Spacer()
                                                        Text("\(ingredient.amount) \(ingredient.measurement)").font(settings.subheadlineFont).foregroundColor(.gray)
                                                    }
                                                    Spacer()
                                                }
                                                .padding()
                                                .background(Color(uiColor: .systemBackground))
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.05), radius: 3)
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                } else {
                                    Text("No ingredients available.")
                                        .foregroundColor(.gray)
                                        .font(settings.subheadlineFont)
                                        .padding(.horizontal)
                                }

                            case .instructions:
                                if !instructions.isEmpty {
                                    ForEach(instructions, id: \.stepNumber) { instruction in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Step \(instruction.stepNumber)")
                                                .font(settings.headlineFont)
                                                .foregroundColor(.pink)
                                            Text(instruction.instructionText)
                                                .font(settings.font)
                                        }
                                        .padding()
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color(uiColor: .systemBackground))
                                                    .cornerRadius(12)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 3)
                                                    .padding(.horizontal)
                                    }
                                } else {
                                    Text("No instructions available.")
                                        .foregroundColor(.gray)
                                        .font(settings.subheadlineFont)
                                        .padding(.horizontal)
                                }

                            case .notes:
                                if let note = recipe.note, !note.isEmpty {
                                    Text(note)
                                        .font(settings.font)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(uiColor: .systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                                        .padding(.horizontal)
                                } else {
                                    Text("No notes available for this recipe.")
                                        .foregroundColor(.gray)
                                        .font(settings.subheadlineFont)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
                .id(refreshID)
            }
            .navigationTitle(recipe.name)
            .background(Color(.systemGray6).ignoresSafeArea())
            .onAppear {
                loadRecipeData()
                if let user = currentUser {
                    isFavorite = RecipeDatabaseManager.shared.isRecipeFavorite(username: user.username, recipeId: recipe.id)
                }
                self.otherImagePaths = getOtherImages(forRecipeId: recipe.id)

                for path in self.otherImagePaths {
                    print("📸 Loaded other image path from DB: \(path)")
                }

                
            }
            .toolbarBackground(Color(uiColor: .secondarySystemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert(isPresented: $showDeletionConfirmation) {
                Alert(
                    title: Text("Delete Recipe"),
                    message: Text("Are you sure you want to delete this recipe?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if deleteRecipe(name: recipe.name) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            NavigationLink(destination: CookModeView(recipeId: recipe.id), isActive: $showCookMode) {
                EmptyView()
            }.hidden()
        }
    }

    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return hours > 0 ? (mins > 0 ? "\(hours) hr \(mins) min" : "\(hours) hr") : "\(mins) min"
    }

    private func loadImage(fromPath path: String) -> UIImage? {
        print("📂 Attempting to load image at path: \(path)")
        return FileManager.default.fileExists(atPath: path) ? UIImage(contentsOfFile: path) : nil
    }





    private func loadRecipeData() {
        self.coverImagePath = getCoverImage(forRecipeId: recipe.id)
        self.otherImagePaths = getOtherImages(forRecipeId: recipe.id)
        self.instructions = fetchInstructions(forRecipeId: recipe.id)
        self.ingredientsBySection = IngredientManager.shared.fetchIngredientsGroupedBySection(recipeId: recipe.id)
    }

    private func getCoverImage(forRecipeId recipeId: Int64) -> String? {
        RecipeDatabaseManager.shared.getCoverImage(forRecipeId: recipeId)
    }

    private func getOtherImages(forRecipeId recipeId: Int64) -> [String] {
        RecipeDatabaseManager.shared.getOtherImages(forRecipeId: recipeId)
    }

    private func fetchInstructions(forRecipeId recipeId: Int64) -> [(stepNumber: Int, instructionText: String)] {
        InstructionsManager.shared.fetchInstructions(recipeId: recipeId)
    }

    private func deleteRecipe() {
        showDeletionConfirmation = true
    }

    private func deleteRecipe(name: String) -> Bool {
        RecipeDatabaseManager.shared.deleteRecipe(name: name)
    }
}
