import SwiftUI

struct RecipeDetailView: View {
    var recipe: (id: Int64, name: String, description: String, time: Int, filters: [String], videoURL: String?)
    
    @State private var coverImagePath: String?
    @State private var otherImagePaths: [String] = []
    @State private var showDeletionConfirmation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(recipe.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Spacer()
                    
                    Button(action: deleteRecipe) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .padding()
                    }
                }

                Text(recipe.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top)

                Text(formatTime(minutes: recipe.time))
                    .font(.subheadline)
                    .foregroundColor(.pink)
                    .padding(.top)

                if let coverImagePath = coverImagePath, let coverImage = loadImage(fromPath: coverImagePath) {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.top)
                }

                if let videoURL = recipe.videoURL, !videoURL.isEmpty {
                    Text("Video URL: \(videoURL)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.top)
                }

                if !recipe.filters.isEmpty {
                    Text("Filters: \(recipe.filters.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                        .padding(.top)
                }

                ForEach(otherImagePaths, id: \.self) { imagePath in
                    if let image = loadImage(fromPath: imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .onAppear {
            if let coverImagePath = getCoverImage(forRecipeId: recipe.id) {
                self.coverImagePath = coverImagePath
            }
            self.otherImagePaths = getOtherImages(forRecipeId: recipe.id)
        }
        .alert(isPresented: $showDeletionConfirmation) {
            Alert(
                title: Text("Delete Recipe"),
                message: Text("Are you sure you want to delete this recipe?"),
                primaryButton: .destructive(Text("Delete")) {
                    if deleteRecipe(name: recipe.name) {
                        print("Recipe deleted successfully")
                    } else {
                        print("Failed to delete recipe")
                    }
                },
                secondaryButton: .cancel()
            )
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

    private func loadImage(fromPath path: String) -> UIImage? {
        if FileManager.default.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        } else {
            print("Image not found at path: \(path)")
            return nil
        }
    }

    private func getCoverImage(forRecipeId recipeId: Int64) -> String? {
        return RecipeDatabaseManager.shared.getCoverImage(forRecipeId: recipeId)
    }

    private func getOtherImages(forRecipeId recipeId: Int64) -> [String] {
        return RecipeDatabaseManager.shared.getOtherImages(forRecipeId: recipeId)
    }

    private func deleteRecipe() {
        showDeletionConfirmation = true
    }

    private func deleteRecipe(name: String) -> Bool {
        return RecipeDatabaseManager.shared.deleteRecipe(name: name)
    }
}
