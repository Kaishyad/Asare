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

    var recipeTable: Table { return recipes }
    var recipeIdExpression: SQLite.Expression<Int64> { return id }

    private let recipeFilters = Table("recipe_filters")
    private let recipeId = SQLite.Expression<Int64>("recipe_id")
    private let filterIdRef = SQLite.Expression<Int64>("filter_id")

    private let favorites = Table("favorites")
    private let favoriteId = SQLite.Expression<Int64>("id")
    private let favoriteUser = SQLite.Expression<String>("username")
    private let favoriteRecipeId = SQLite.Expression<Int64>("recipe_id")

    private init() {
        db = ConnectionManager.shared.getConnection() // Get connection from ConnectionManager
        //dropTables()  // Delete existing tables
        createRecipesTable()
        createRecipeFiltersTable()
        createFavoritesTable()
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
                t.column(time) // Add the time column
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

    // MARK: - Basic Recipe

    func addRecipe(username: String, name: String, description: String, time: Int, selectedFilters: [String], ingredients: [(name: String, amount: String, measurement: String)], instructions: [(stepNumber: Int, instructionText: String)]) -> Bool {
        do {
            // Insert recipe into the database
            guard let recipeId = try db?.run(recipes.insert(self.username <- username, self.name <- name, self.description <- description, self.time <- time)) else {
                print("Error: Failed to insert recipe.")
                return false
            }

            // Add ingredients to the recipe
            IngredientManager.shared.addIngredients(recipeId: recipeId, ingredientList: ingredients)

            // ✅ Add instructions to the recipe using InstructionsManager
            // Pass the instructions array with both stepNumber and instructionText
            InstructionsManager.shared.addInstructions(recipeId: recipeId, instructionsList: instructions)

            // Insert relationships between recipe and filters
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


    func fetchRecipesForUser(username: String, completion: @escaping ([(id: Int64, name: String, description: String, filters: [String])]) -> Void) {
        do {
            let query = recipes.filter(self.username == username)
            var fetchedRecipes: [(id: Int64, name: String, description: String, filters: [String])] = []

            let allRecipes = try db?.prepare(query)

            for recipe in allRecipes! {
                let recipeId = recipe[self.id]
                let recipeName = recipe[self.name]
                let recipeDescription = recipe[self.description]

                let filtersQuery = recipeFilters.filter(self.recipeId == recipe[self.id])
                    .join(FilterManager.shared.getFiltersTable(), on: FilterManager.shared.getFiltersTable()[FilterManager.shared.getFilterIdExpression()] == recipeFilters[self.filterIdRef])

                var recipeFiltersList: [String] = []
                for filter in try db!.prepare(filtersQuery) {
                    recipeFiltersList.append(filter[FilterManager.shared.getFilterNameExpression()])
                }

                fetchedRecipes.append((id: recipeId, name: recipeName, description: recipeDescription, filters: recipeFiltersList))
            }

            completion(fetchedRecipes)
        } catch {
            print("Error fetching recipes with filters: \(error)")
            completion([])
        }
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
