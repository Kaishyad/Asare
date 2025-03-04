
import Foundation
import SQLite
class IngredientManager {
    static let shared = IngredientManager()
    private var db: Connection?

    private let ingredients = Table("ingredients")
    private let id = SQLite.Expression<Int64>("id")
    private let recipeId = SQLite.Expression<Int64>("recipe_id")
    private let name = SQLite.Expression<String>("name")
    private let amount = SQLite.Expression<String>("amount")  // Added amount field
    private let measurement = SQLite.Expression<String>("measurement")

    private init() {
        db = ConnectionManager.shared.getConnection()
        createIngredientsTable()
    }

    private func createIngredientsTable() {
        do {
            try db?.run(ingredients.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(recipeId, references: RecipeDatabaseManager.shared.recipes, RecipeDatabaseManager.shared.id)
                t.column(name)
                t.column(amount)  // Include amount in the table
                t.column(measurement)
            })
            print("Ingredients table created successfully!")
        } catch {
            print("Error creating ingredients table: \(error)")
        }
    }

    // MARK: - Ingredient Management

    func addIngredients(recipeId: Int64, ingredientList: [(name: String, amount: String, measurement: String)]) {
        do {
            for ingredient in ingredientList {
                try db?.run(ingredients.insert(self.recipeId <- recipeId, self.name <- ingredient.name, self.amount <- ingredient.amount, self.measurement <- ingredient.measurement))
            }
            print("Ingredients added successfully!")
        } catch {
            print("Error adding ingredients: \(error)")
        }
    }

    func fetchIngredientsForRecipe(recipeId: Int64) -> [(name: String, amount: String, measurement: String)] {
        var ingredientList: [(name: String, amount: String, measurement: String)] = []
        do {
            for ingredient in try db!.prepare(ingredients.filter(self.recipeId == recipeId)) {
                let name = ingredient[self.name]
                let amount = ingredient[self.amount] // Fetch amount
                let measurement = ingredient[self.measurement]
                ingredientList.append((name, amount, measurement))
            }
        } catch {
            print("Error fetching ingredients: \(error)")
        }
        return ingredientList
    }
}
