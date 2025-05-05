import XCTest
@testable import Asare

final class IngredientManagerTests: XCTestCase {
    
    var manager: IngredientManager!
    let testRecipeId: Int64 = 88888

    override func setUpWithError() throws {
        manager = IngredientManager.shared
       // manager.dropIngredientsTable()
        //manager.createIngredientsTable()
    }

    override func tearDownWithError() throws {
        manager.dropIngredientsTable()
    }

    func testAddAndFetchIngredients() throws {
        let ingredients = [
            (name: "Flour", amount: "2", measurement: "cups", section: "Dry"),
            (name: "Milk", amount: "1", measurement: "cup", section: "Wet")
        ]
        
        manager.addIngredients(recipeId: testRecipeId, ingredientList: ingredients)
        let fetched = manager.fetchIngredientsForRecipe(recipeId: testRecipeId)

        XCTAssertEqual(fetched.count, 2)
        XCTAssertEqual(fetched[1].section, "Wet") //check if this is the right ingredient
    }



    func testEmptyResultWhenNoIngredients() throws {
        let fetched = manager.fetchIngredientsForRecipe(recipeId: testRecipeId)
        XCTAssertTrue(fetched.isEmpty)
    }
}
