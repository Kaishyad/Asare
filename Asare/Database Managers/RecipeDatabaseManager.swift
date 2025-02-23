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
        } catch {
            print("Error initializing database: \(error)")
        }
    }

    private func createTables() {
        do {
            // Create recipes table if not exists
            try db?.run(recipes.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(username)
                t.column(name)
                t.column(description)
            })

            // Create filters table if not exists
            try db?.run(filters.create(ifNotExists: true) { t in
                t.column(filterId, primaryKey: true)
                t.column(filterName)
            })

            // Create many-to-many table between recipes and filters
            try db?.run(recipeFilters.create(ifNotExists: true) { t in
                t.column(recipeId)
                t.column(filterIdRef)
                t.foreignKey(recipeId, references: recipes, id)
                t.foreignKey(filterIdRef, references: filters, filterId)
            })

            print("Tables created successfully!")
        } catch {
            print("Error creating tables: \(error)")
        }
    }

    func addFilter(name: String) -> Bool {
        do {
            try db?.run(filters.insert(filterName <- name))
            return true
        } catch {
            print("Error adding filter: \(error)")
            return false
        }
    }

    func addRecipe(username: String, name: String, description: String, selectedFilters: [String]) -> Bool {
        do {
            let recipeId = try db?.run(recipes.insert(self.username <- username, self.name <- name, self.description <- description))

            //Insert the filters for the recipe
            for filterName in selectedFilters {
                let filter = filters.filter(self.filterName == filterName)
                if let filterRow = try db?.pluck(filter) {
                    let filterIdValue = filterRow[self.filterId]
                    try db?.run(recipeFilters.insert(self.recipeId <- recipeId!, self.filterIdRef <- filterIdValue))
                }
            }

            return true
        } catch {
            print("Error adding recipe with filters: \(error)")
            return false
        }
    }

    //Fetch recipes for a specific user along with filters
    func fetchRecipesForUser(username: String, completion: @escaping ([(name: String, description: String, filters: [String])]) -> Void) {
        do {
            let query = recipes.filter(self.username == username)
            let allRecipes = try db?.prepare(query)
            var fetchedRecipes: [(name: String, description: String, filters: [String])] = []

            for recipe in allRecipes! {
                let recipeName = recipe[self.name]
                let recipeDescription = recipe[self.description]

                // Fetch filters associated with this recipe
                let filtersQuery = recipeFilters.filter(self.recipeId == recipe[self.id])
                    .join(filters, on: filters[self.filterId] == recipeFilters[self.filterIdRef])

                var recipeFiltersList: [String] = []
                for filter in try db!.prepare(filtersQuery) {
                    recipeFiltersList.append(filter[filters[self.filterName]])
                }

                fetchedRecipes.append((name: recipeName, description: recipeDescription, filters: recipeFiltersList))
            }

            completion(fetchedRecipes)
        } catch {
            print("Error fetching recipes with filters: \(error)")
            completion([]) // Return empty array on error
        }
    }
}
