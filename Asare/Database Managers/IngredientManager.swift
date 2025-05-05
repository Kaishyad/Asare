import Foundation
import SQLite

class IngredientManager {
    static let shared = IngredientManager()
    private var db: Connection?

    private let ingredients = Table("ingredients")
    private let id = SQLite.Expression<Int64>("id")
    private let recipeId = SQLite.Expression<Int64>("recipe_id")
    private let name = SQLite.Expression<String>("name")
    private let amount = SQLite.Expression<String>("amount")
    private let measurement = SQLite.Expression<String>("measurement")
    private let section = SQLite.Expression<String>("section")

    private init() {
        db = ConnectionManager.shared.getConnection()
        guard db != nil else {
            print("Database connection failed!")
            return
        }
      //  dropIngredientsTable()
        createIngredientsTable()
    }

    private func createIngredientsTable() {
        do {
            try db?.run(ingredients.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(recipeId, references: RecipeDatabaseManager.shared.recipes, RecipeDatabaseManager.shared.id)
                t.column(name)
                t.column(amount)
                t.column(measurement)
                t.column(section)
            })
            print("Ingredients table created successfully!")
        } catch {
            print("Error creating ingredients table: \(error)")
        }
    }

    func dropIngredientsTable() {
        do {
            try db?.run(ingredients.drop(ifExists: true))
            print("Ingredients table dropped successfully!")
        } catch {
            print("Error dropping ingredients table: \(error.localizedDescription)")
        }
    }

    func addIngredients(recipeId: Int64, ingredientList: [(name: String, amount: String, measurement: String, section: String)]) {
        do {
            for ingredient in ingredientList {
                try db?.run(ingredients.insert(
                    self.recipeId <- recipeId,
                    self.name <- ingredient.name,
                    self.amount <- ingredient.amount,
                    self.measurement <- ingredient.measurement,
                    self.section <- ingredient.section
                ))
            }
            print("Ingredients added successfully!")
        } catch {
            print("Error adding ingredients: \(error)")
        }
    }

    func fetchIngredientsForRecipe(recipeId: Int64) -> [(name: String, amount: String, measurement: String, section: String)] {
        var ingredientList: [(name: String, amount: String, measurement: String, section: String)] = []
        do {
            for ingredient in try db!.prepare(ingredients.filter(self.recipeId == recipeId)) {
                let name = ingredient[self.name]
                let amount = ingredient[self.amount]
                let measurement = ingredient[self.measurement]
                let section = ingredient[self.section]
                ingredientList.append((name, amount, measurement, section))
            }
        } catch {
            print("Error fetching ingredients: \(error)")
        }
        return ingredientList
    }

    func fetchIngredientsGroupedBySection(recipeId: Int64) -> [String: [(name: String, amount: String, measurement: String)]] {
        var groupedIngredients: [String: [(name: String, amount: String, measurement: String)]] = [:]
        do {
            let query = ingredients.filter(self.recipeId == recipeId)
            for row in try db!.prepare(query) {
                let section = row[self.section]
                let ingredient = (
                    name: row[self.name],
                    amount: row[self.amount],
                    measurement: row[self.measurement]
                )
                groupedIngredients[section, default: []].append(ingredient)
            }
        } catch {
            print("Error fetching ingredients grouped by section: \(error)")
        }
        return groupedIngredients
    }
    
    func replaceIngredients(for recipeId: Int64, with ingredientList: [(name: String, amount: String, measurement: String, section: String)]) {
        
        do {
            let deleteQuery = ingredients.filter(self.recipeId == recipeId)
            try db?.run(deleteQuery.delete())

            for ingredient in ingredientList {
                try db?.run(ingredients.insert(
                    self.recipeId <- recipeId,
                    self.name <- ingredient.name,
                    self.amount <- ingredient.amount,
                    self.measurement <- ingredient.measurement,
                    self.section <- ingredient.section
                ))
            }

            print("Replaced ingredients for recipe \(recipeId)")
        } catch {
            print("Error replacing ingredients: \(error)")
        }
    }
    func fetchIngredientObjectsGroupedBySection(recipeId: Int64) -> [String: [Ingredient]] {
        var groupedIngredients: [String: [Ingredient]] = [:]
        do {
            let query = ingredients.filter(self.recipeId == recipeId)
            for row in try db!.prepare(query) {
                let section = row[self.section]
                let ingredient = Ingredient(
                    id: row[self.id],
                    name: row[self.name],
                    amount: row[self.amount],
                    measurement: row[self.measurement]
                )
                groupedIngredients[section, default: []].append(ingredient)
            }
        } catch {
            print("Error fetching ingredient objects grouped by section: \(error)")
        }
        return groupedIngredients
    }
}

struct Ingredient: Identifiable, Hashable {
    let id: Int64
    let name: String
    let amount: String
    let measurement: String
}
