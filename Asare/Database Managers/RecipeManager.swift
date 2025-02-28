import Foundation
import SQLite

class RecipeManager {
    private var db: Connection?

    private let recipes = Table("recipes")
    private let id = Expression<Int64>("id")
    private let username = Expression<String>("username")
    private let name = Expression<String>("name")
    private let description = Expression<String>("description")

    init() {
        self.db = ConnectionManager.shared.getConnection() // Get connection from ConnectionManager
        createRecipesTable()
    }

    private func createRecipesTable() {
        do {
            try db?.run(recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(username)
                t.column(name)
                t.column(description)
            })
            print("Recipes table created successfully!")
        } catch {
            print("Error creating recipes table: \(error)")
        }
    }

    func addRecipe(username: String, name: String, description: String, selectedFilters: [String]) -> Bool {
        do {
            // Insert the recipe into the recipes table
            let recipeId = try db?.run(recipes.insert(self.username <- username, self.name <- name, self.description <- description))
            
            // Handle filters by using FilterManager to insert the relationships
            for filter in selectedFilters {
                if let filterId = try FilterManager.shared.getFilterIdByName(filter) {
                    let recipeFilters = Table("recipe_filters")
                    let recipeIdColumn = Expression<Int64>("recipe_id")
                    let filterIdColumn = Expression<Int64>("filter_id")
                    
                    // Insert the relationship between recipe and filter
                    try db?.run(recipeFilters.insert(recipeIdColumn <- recipeId!, filterIdColumn <- filterId))
                }
            }
            return true
        } catch {
            print("Error adding recipe: \(error)")
            return false
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

    func fetchRecipesForUser(username: String, completion: @escaping ([(name: String, description: String, filters: [String])]) -> Void) {
        do {
            let query = recipes.filter(self.username == username)
            let allRecipes = try db?.prepare(query)
            
            var recipesWithFilters: [(name: String, description: String, filters: [String])] = []
            
            for recipe in allRecipes! {
                let recipeName = recipe[self.name]
                let recipeDescription = recipe[self.description]
                
                // Fetch filters associated with the recipe
                let recipeFilters = Table("recipe_filters")
                let filterId = Expression<Int64>("filter_id")
                
                let filtersQuery = recipeFilters.filter(recipeFilters[recipeId] == recipe[self.id])
                    .join(FilterManager.shared.filters, on: FilterManager.shared.filters[filterId] == recipeFilters[filterId])
                
                var filtersList: [String] = []
                for filter in try db!.prepare(filtersQuery) {
                    filtersList.append(filter[FilterManager.shared.filters[filterName]])
                }
                
                recipesWithFilters.append((name: recipeName, description: recipeDescription, filters: filtersList))
            }
            
            completion(recipesWithFilters)
        } catch {
            print("Error fetching recipes: \(error)")
            completion([])
        }
    }
}
