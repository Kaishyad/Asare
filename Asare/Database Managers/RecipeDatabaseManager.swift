import SQLite
import Foundation

class RecipeDatabaseManager {
    static let shared = RecipeDatabaseManager()
    private var db: Connection?

    // Use SQLite.Expression explicitly
    let recipes = Table("recipes")
    let id = SQLite.Expression<Int64>("id")
    private let username = SQLite.Expression<String>("username")
    private let name = SQLite.Expression<String>("name")
    private let description = SQLite.Expression<String>("description")
    private let time = SQLite.Expression<Int>("time") // Add time as an integer (minutes)
    private let videoURL = SQLite.Expression<String?>("video_url") // Optional YouTube/website URL

    var recipeTable: Table { return recipes }
    var recipeIdExpression: SQLite.Expression<Int64> { return id }

    private let recipeFilters = Table("recipe_filters")
    private let recipeId = SQLite.Expression<Int64>("recipe_id")
    private let filterIdRef = SQLite.Expression<Int64>("filter_id")

    private let favorites = Table("favorites")
    private let favoriteId = SQLite.Expression<Int64>("id")
    private let favoriteUser = SQLite.Expression<String>("username")
    private let favoriteRecipeId = SQLite.Expression<Int64>("recipe_id")

    private let coverImage = SQLite.Expression<String?>("cover_image") // Optional image path
    
    private let recipeImages = Table("recipe_images")
    private let imageId = SQLite.Expression<Int64>("id")
    private let imagePath = SQLite.Expression<String>("image_path") // Image path

    private init() {
        db = ConnectionManager.shared.getConnection() // Get connection from ConnectionManager
        //dropTables()  // Delete existing tables
        createRecipesTable()
        createRecipeFiltersTable()
        createFavoritesTable()
        createRecipeImagesTable()
    }

    private func dropTables() {
        do {
            try db?.run("DROP TABLE IF EXISTS recipes")
            try db?.run("DROP TABLE IF EXISTS recipe_filters")
            try db?.run("DROP TABLE IF EXISTS favorites")

            print("Tables dropped successfully!")
        } catch {
            print("Error dropping tables: \(error)")
        }
    }
    
    // MARK: - Tables

    private func createRecipesTable() {
        do {
            try db?.run(recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(username)
                t.column(name)
                t.column(description)
                t.column(time)
                t.column(coverImage)
                t.column(videoURL) 
            })
            print("Recipes table created successfully!")
        } catch {
            print("Error creating recipes table: \(error)")
        }
    }

    private func createFavoritesTable() {
        do {
            try db?.run(favorites.create(ifNotExists: true) { t in
                t.column(favoriteId, primaryKey: true)
                t.column(favoriteUser)
                t.column(favoriteRecipeId)
                t.foreignKey(favoriteRecipeId, references: recipes, id) // Links to recipes table
            })
            print("Favorites table created successfully!")
        } catch {
            print("Error creating favorites table: \(error)")
        }
    }

    private func createRecipeFiltersTable() {
        do {
            try db?.run(recipeFilters.create(ifNotExists: true) { t in
                t.column(recipeId, references: recipes, id)
                t.column(filterIdRef, references: FilterManager.shared.getFiltersTable(), FilterManager.shared.getFilterIdExpression())
            })
            print("RecipeFilters table created successfully!")
        } catch {
            print("Error creating recipe_filters table: \(error)")
        }
    }
    
    private func createRecipeImagesTable() {
        do {
            try db?.run(recipeImages.create(ifNotExists: true) { t in
                t.column(imageId, primaryKey: true)
                t.column(recipeId, references: recipes, id) // Link to recipes table
                t.column(imagePath) // Store image path
            })
            print("RecipeImages table created successfully!")
        } catch {
            print("Error creating recipe_images table: \(error)")
        }
    }

    // MARK: - Basic Recipe

    func addRecipe(username: String, name: String, description: String, time: Int, selectedFilters: [String], ingredients: [(name: String, amount: String, measurement: String)], instructions: [(stepNumber: Int, instructionText: String)], coverImagePath: String?, otherImages: [String], videoURL: String?) -> Bool {
        do {
            guard let recipeId = try db?.run(recipes.insert(
                self.username <- username,
                self.name <- name,
                self.description <- description,
                self.time <- time,
                self.coverImage <- coverImagePath,
                self.videoURL <- videoURL // Store video URL
            )) else {
                print("Error: Failed to insert recipe.")
                return false
            }

            // Add multiple images
            for imagePath in otherImages {
                try db?.run(recipeImages.insert(self.recipeId <- recipeId, self.imagePath <- imagePath))
            }

            // Add ingredients & instructions
            IngredientManager.shared.addIngredients(recipeId: recipeId, ingredientList: ingredients)
            InstructionsManager.shared.addInstructions(recipeId: recipeId, instructionsList: instructions)

            // Add filters
            for filter in selectedFilters {
                if let filterIdValue = FilterManager.shared.getFilterIdByName(filter) {
                    try db?.run(recipeFilters.insert(self.recipeId <- recipeId, self.filterIdRef <- filterIdValue))
                }
            }

            return true
        } catch {
            print("Error adding recipe: \(error)")
            return false
        }
    }



    func fetchRecipesForUser(username: String, completion: @escaping ([(id: Int64, name: String, description: String, time: Int, filters: [String])]) -> Void) {
        do {
            let query = recipes.filter(self.username == username)
            var fetchedRecipes: [(id: Int64, name: String, description: String, time: Int, filters: [String])] = []

            let allRecipes = try db?.prepare(query)

            for recipe in allRecipes! {
                let recipeId = recipe[self.id]
                let recipeName = recipe[self.name]
                let recipeDescription = recipe[self.description]
                let recipeTime = recipe[self.time] // Fetching time (in minutes)

                let filtersQuery = recipeFilters
                    .filter(self.recipeId == recipe[self.id])
                    .join(FilterManager.shared.getFiltersTable(), on:
                        FilterManager.shared.getFiltersTable()[FilterManager.shared.getFilterIdExpression()] == recipeFilters[self.filterIdRef]
                    )

                var recipeFiltersList: [String] = []
                for filter in try db!.prepare(filtersQuery) {
                    recipeFiltersList.append(filter[FilterManager.shared.getFilterNameExpression()])
                }

                fetchedRecipes.append((id: recipeId, name: recipeName, description: recipeDescription, time: recipeTime, filters: recipeFiltersList))
            }

            completion(fetchedRecipes)
        } catch {
            print("Error fetching recipes with filters: \(error)")
            completion([])
        }
    }
    
    func fetchOtherImages(recipeId: Int64) -> [String] {
        var images: [String] = []
        do {
            let query = recipeImages.filter(self.recipeId == recipeId)
            for row in try db!.prepare(query) {
                images.append(row[self.imagePath])
            }
        } catch {
            print("Error fetching images: \(error)")
        }
        return images
    }


    func deleteRecipe(name: String) -> Bool {
        do {
            let recipeToDelete = recipes.filter(self.name == name)
            try db?.run(recipeToDelete.delete())
            return true
        } catch {
            print("Error deleting recipe: \(error)")
            return false
        }
    }

    // MARK: - Favorites
    func addFavorite(username: String, recipeId: Int64) -> Bool {
        do {
            try db?.run(favorites.insert(favoriteUser <- username, favoriteRecipeId <- recipeId))
            print("Recipe \(recipeId) added to favorites for user \(username).")
            return true
        } catch {
            print("Error adding favorite: \(error)")
            return false
        }
    }

    func removeFavorite(username: String, recipeId: Int64) -> Bool {
        do {
            let favoriteToDelete = favorites.filter(favoriteUser == username && favoriteRecipeId == recipeId)
            try db?.run(favoriteToDelete.delete())
            print("Recipe \(recipeId) removed from favorites for user \(username).")
            return true
        } catch {
            print("Error removing favorite: \(error)")
            return false
        }
    }

    func getFavoritesForUser(username: String) -> [Int64] {
        var favoriteRecipes: [Int64] = []
        do {
            for row in try db!.prepare(favorites.filter(favoriteUser == username)) {
                favoriteRecipes.append(row[favoriteRecipeId])
            }
        } catch {
            print("Error fetching favorites: \(error)")
        }
        return favoriteRecipes
    }

    func isRecipeFavorite(username: String, recipeId: Int64) -> Bool {
        do {
            let query = favorites.filter(favoriteUser == username && favoriteRecipeId == recipeId)
            return try db?.pluck(query) != nil
        } catch {
            print("Error checking favorite status: \(error)")
            return false
        }
    }

    func getRecipeIdByName(_ name: String) -> Int64? {
        do {
            let query = recipes.filter(self.name == name)
            if let recipe = try db?.pluck(query) {
                return recipe[self.id]
            }
        } catch {
            print("Error fetching recipe ID: \(error)")
        }
        return nil
    }
    
    
}
