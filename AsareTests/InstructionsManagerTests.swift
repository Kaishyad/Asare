import XCTest
@testable import Asare

final class InstructionsManagerTests: XCTestCase {

    var manager: InstructionsManager!
    let testRecipeId: Int64 = 99999

    override func setUpWithError() throws {
        manager = InstructionsManager.shared
    }

    override func tearDownWithError() throws {
        manager.dropInstructionsTable()
    }

    func testAddAndFetchInstructions() throws {
        let testInstructions = [
            (stepNumber: 1, instructionText: "Boil water"),
            (stepNumber: 2, instructionText: "Add pasta"),
            (stepNumber: 3, instructionText: "Stir occasionally")
        ]

        manager.addInstructions(recipeId: testRecipeId, instructionsList: testInstructions)
        let fetched = manager.fetchInstructions(recipeId: testRecipeId)

        XCTAssertEqual(fetched.count, 3, "Expected 3 fetched instructions")
        XCTAssertEqual(fetched[0].instructionText, "Boil water")
        XCTAssertEqual(fetched[1].stepNumber, 2)
    }

    func testDeleteInstructionAndUpdateSteps() throws {
        let testInstructions = [
            (stepNumber: 1, instructionText: "Step 1"),
            (stepNumber: 2, instructionText: "Step 2"),
            (stepNumber: 3, instructionText: "Step 3")
        ]

        manager.addInstructions(recipeId: testRecipeId, instructionsList: testInstructions)
        manager.deleteInstruction(recipeId: testRecipeId, stepNumber: 2)

        let updated = manager.fetchInstructions(recipeId: testRecipeId)

        XCTAssertEqual(updated.count, 2)
        XCTAssertEqual(updated[0].stepNumber, 1)
        XCTAssertEqual(updated[1].stepNumber, 2)
        XCTAssertEqual(updated[1].instructionText, "Step 3")
    }

    func testAddInstructionsResetsOldOnes() throws {
        let original = [
            (stepNumber: 1, instructionText: "Old step 1"),
            (stepNumber: 2, instructionText: "Old step 2")
        ]
        let updated = [
            (stepNumber: 1, instructionText: "New step 1")
        ]

        manager.addInstructions(recipeId: testRecipeId, instructionsList: original)
        manager.addInstructions(recipeId: testRecipeId, instructionsList: updated)

        let result = manager.fetchInstructions(recipeId: testRecipeId)
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result.isEmpty, "Expected at least one instruction but got none.")
        //XCTAssertEqual(result[0].instructionText, "New step 1")
    }
}
