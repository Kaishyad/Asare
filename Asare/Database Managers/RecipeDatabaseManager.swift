import SQLite
import Foundation

class RecipeDatabaseManager {
    static let shared = RecipeDatabaseManager()
    private var db: Connection?

    private let recipes = Table("recipes")
    private let id = Expression<Int64>("id")
    private let username = Expression<String>("username")
    private let name = Expression<String>("name")
    private let description = Expression<String>("description")

    private let filters = Table("filters")
    private let filterId = Expression<Int64>("id")
    private let filterName = Expression<String>("name")

    private let recipeFilters = Table("recipe_filters")
    private let recipeId = Expression<Int64>("recipe_id")
    private let filterIdRef = Expression<Int64>("filter_id")

    private let favorites = Table("favorites")
    private let favoriteId = Expression<Int64>("id")
    private let recipeIdRef = Expression<Int64>("recipe_id")

    private let defaultFilters = ["Vegetarian", "Quick", "Spicy", "High-Protein", "Gluten-Free", "Vegan", "Dairy-Free", "Keto"]

    private init() {
        do {
            let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("app_database.sqlite")
                .path
            print("Database path: \(path)")

            db = try Connection(path)
            createTables()
            insertDefaultFilters() // Adds default filters
        } catch {
            print("Error initializing database: \(error)")
        }
    }

    private func createTables() {
        do {
            try db?.run(recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(username)
                t.column(name)
                t.column(description)
                t.column(description)
            })

            try db?.run(filters.create(ifNotExists: true) { t in
                t.column(filterId, primaryKey: true)
                t.column(filterName, unique: true)
            })

            try db?.run(recipeFilters.create(ifNotExists: true) { t in
                t.column(recipeId)
                t.column(filterIdRef)
                t.foreignKey(recipeId, references: recipes, id)
                t.foreignKey(filterIdRef, references: filters, filterId)
            })
            try db?.run(favorites.create(ifNotExists: true) { t in
                t.column(favoriteId, primaryKey: true)
                t.column(recipeIdRef)
                t.column(username)
                t.foreignKey(recipeIdRef, references: recipes, id)
            })

            print("Tables created successfully!")
        } catch {
            print("Error creating tables: \(error)")
        }
    }
    func addFavorite(recipeId: Int64, username: String) -> Bool {
        do {
            let existingFavorite = favorites.filter(recipeIdRef == recipeId && self.username == username)
            if try db?.pluck(existingFavorite) == nil {
                try db?.run(favorites.insert(recipeIdRef <- recipeId, self.username <- username))
            }
            return true
        } catch {
            print("Error adding favorite: \(error)")
            return false
        }
    }

    func removeFavorite(recipeId: Int64, username: String) -> Bool {
        do {
            let favoriteToDelete = favorites.filter(recipeIdRef == recipeId && self.username == username)
            try db?.run(favoriteToDelete.delete())
            return true
        } catch {
            print("Error removing favorite: \(error)")
            return false
        }
    }

    func getFavoritesForUser(username: String) -> [Int64] {
        do {
            return try db?.prepare(favorites.filter(self.username == username)).map { $0[recipeIdRef] } ?? []
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    func isFavorite(recipeId: Int64, username: String) -> Bool {
        do {
            return try db?.pluck(favorites.filter(recipeIdRef == recipeId && self.username == username)) != nil
        } catch {
            print("Error checking favorite status: \(error)")
            return false
        }
    }




    private func insertDefaultFilters() {
        do {
            for filter in defaultFilters {
                let existingFilter = filters.filter(filterName == filter)
                if try db?.pluck(existingFilter) == nil {
                    try db?.run(filters.insert(filterName <- filter))
                }
            }
            print("Default filters added!")
        } catch {
            print("Error inserting default filters: \(error)")
        }
    }

    func addFilter(name: String) -> Bool {
        do {
            let existingFilter = filters.filter(filterName == name)
            if try db?.pluck(existingFilter) == nil {
                try db?.run(filters.insert(filterName <- name))
            }
            return true
        } catch {
            print("Error adding filter: \(error)")
            return false
        }
    }

    func getAllFilters() -> [String] {
        do {
            return try db?.prepare(filters).map { $0[filterName] } ?? []
        } catch {
            print("Error fetching filters: \(error)")
            return []
        }
    }

    func addRecipe(username: String, name: String, description: String, selectedFilters: [String]) -> Int64? {
        do {
            let recipeId = try db?.run(recipes.insert(self.username <- username, self.name <- name, self.description <- description))
            guard let newRecipeId = recipeId else { return nil } // Ensure recipeId is valid

            for filter in selectedFilters {
                let filterQuery = filters.filter(filterName == filter)
                if let filterRow = try db?.pluck(filterQuery) {
                    let filterIdValue = filterRow[filterId]
                    try db?.run(recipeFilters.insert(self.recipeId <- newRecipeId, self.filterIdRef <- filterIdValue))
                }
            }

            return newRecipeId
        } catch {
            print("Error adding recipe with filters: \(error)")
            return nil
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

    func deleteFilter(name: String) -> Bool {
        do {
            let filterToDelete = filters.filter(filterName == name)

            if let filterRow = try db?.pluck(filterToDelete) {
                let filterIdValue = filterRow[filterId]
                let filterAssociations = recipeFilters.filter(filterIdRef == filterIdValue)
                try db?.run(filterAssociations.delete())
            }

            try db?.run(filterToDelete.delete())
            
            return true
        } catch {
            print("Error deleting filter: \(error)")
            return false
        }
    }

    func fetchRecipesForUser(username: String, completion: @escaping ([(name: String, description: String, filters: [String], isFavorite: Bool)]) -> Void) {
        do {
            let query = recipes.filter(self.username == username)
            let allRecipes = try db?.prepare(query)
            var fetchedRecipes: [(name: String, description: String, filters: [String], isFavorite: Bool)] = []

            for recipe in allRecipes! {
                let recipeName = recipe[self.name]
                let recipeDescription = recipe[self.description]

                let filtersQuery = recipeFilters.filter(self.recipeId == recipe[self.id])
                    .join(filters, on: filters[self.filterId] == recipeFilters[self.filterIdRef])

                var recipeFiltersList: [String] = []
                for filter in try db!.prepare(filtersQuery) {
                    recipeFiltersList.append(filter[filters[self.filterName]])
                }

                // Check if the recipe is a favorite for the user
                let isFavorite = try db?.pluck(favorites.filter(recipeIdRef == recipe[self.id] && self.username == username)) != nil

                fetchedRecipes.append((name: recipeName, description: recipeDescription, filters: recipeFiltersList, isFavorite: isFavorite))
            }

            completion(fetchedRecipes)
        } catch {
            print("Error fetching recipes with filters: \(error)")
            completion([])
        }
    }

}
