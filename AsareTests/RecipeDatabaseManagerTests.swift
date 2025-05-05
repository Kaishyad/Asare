import XCTest
import SQLite

@testable import Asare

class RecipeDatabaseManagerTests: XCTestCase {

    // MARK: - Helper Before the Tests

    @discardableResult
    func addTestRecipe(username: String = "testUser", name: String = "Test Recipe") -> Int64 {
        let description = "This is a test recipe"
        let time = 30
        let selectedFilters = ["Vegan", "Gluten-Free"]
        let ingredients: [(String, String, String, String)] = [("Tomato", "1", "kg", "Vegetables")]
        let instructions: [(Int, String)] = [(1, "Cut the tomato")]
        let coverImagePath = "test_image_path"
        let otherImages = ["image1.jpg", "image2.jpg"]
        let videoURL = "http://video.com/test_video"
        let note = "Test note"

        let result = RecipeDatabaseManager.shared.addRecipe(
            username: username,
            name: name,
            description: description,
            time: time,
            selectedFilters: selectedFilters,
            ingredients: ingredients,
            instructions: instructions,
            coverImagePath: coverImagePath,
            otherImages: otherImages,
            videoURL: videoURL,
            note: note
        )

        XCTAssertTrue(result, "Failed to add recipe")

        guard let id = RecipeDatabaseManager.shared.getRecipeIdByName(name) else {
            XCTFail("Failed to get recipe ID")
            return -1
        }

        return id
    }

    override func setUp() {
        super.setUp()
        RecipeDatabaseManager.shared.clearDatabase()
    }

    // MARK: - Tests

    func testAddRecipe() {
        _ = addTestRecipe()
    }

    func testFetchRecipesForUser() {
        let username = "testUser"
        let name = "Test Recipe"
        addTestRecipe(username: username, name: name)

        let expectation = self.expectation(description: "Fetch recipes")
        RecipeDatabaseManager.shared.fetchRecipesForUser(username: username) { recipes in
            XCTAssertEqual(recipes.count, 1)
            XCTAssertEqual(recipes[0].name, name)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0)
    }

    func testFetchCoverImage() {
        let recipeId = addTestRecipe()
        if let fetchedCoverImage = RecipeDatabaseManager.shared.getCoverImage(forRecipeId: recipeId) {
            XCTAssertEqual(fetchedCoverImage, "test_image_path")
        } else {
            XCTFail("Failed to fetch cover image")
        }
    }

    func testAddFavorite() {
        let recipeId = addTestRecipe()
        let result = RecipeDatabaseManager.shared.addFavorite(username: "testUser", recipeId: recipeId)
        XCTAssertTrue(result)
    }

    func testRemoveFavorite() {
        let username = "testUser"
        let recipeId = addTestRecipe(username: username)
        RecipeDatabaseManager.shared.addFavorite(username: username, recipeId: recipeId)
        let result = RecipeDatabaseManager.shared.removeFavorite(username: username, recipeId: recipeId)
        XCTAssertTrue(result)
    }

    func testDeleteRecipe() {
        let name = "Test Recipe"
        _ = addTestRecipe(name: name)
        let result = RecipeDatabaseManager.shared.deleteRecipe(name: name)
        XCTAssertTrue(result)
    }

    func testGetFavoritesForUser() {
        let username = "testUser"
        let recipeId = addTestRecipe(username: username)
        RecipeDatabaseManager.shared.addFavorite(username: username, recipeId: recipeId)
        let favorites = RecipeDatabaseManager.shared.getFavoritesForUser(username: username)
        XCTAssertEqual(favorites.count, 1)
    }

    func testIsRecipeFavorite() {
        let username = "testUser"
        let recipeId = addTestRecipe(username: username)
        RecipeDatabaseManager.shared.addFavorite(username: username, recipeId: recipeId)
        let isFavorite = RecipeDatabaseManager.shared.isRecipeFavorite(username: username, recipeId: recipeId)
        XCTAssertTrue(isFavorite)
    }
}
