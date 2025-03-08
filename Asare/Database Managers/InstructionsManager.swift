import Foundation
import SQLite

class InstructionsManager {
    static let shared = InstructionsManager()
    private var db: Connection?

    private let instructions = Table("instructions")
    private let id = SQLite.Expression<Int64>("id")
    private let recipeId = SQLite.Expression<Int64>("recipe_id")
    private let stepNumber = SQLite.Expression<Int>("step_number")
    private let instructionText = SQLite.Expression<String>("instruction_text")

    private init() {
        db = ConnectionManager.shared.getConnection()
        //dropInstructionsTable()
        createInstructionsTable()
    }

    private func createInstructionsTable() {
        do {
            try db?.run(instructions.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(recipeId)
                t.column(stepNumber)
                t.column(instructionText)
            })
        } catch {
            print("Error creating instructions table: \(error)")
        }
    }
    func dropInstructionsTable() {
        do {
            try db?.run(instructions.drop(ifExists: true)) 
            print("Ingredients table dropped successfully!")
        } catch {
            print("Error dropping ingredients table: \(error.localizedDescription)")
        }
    }
    func addInstructions(recipeId: Int64, instructionsList: [(stepNumber: Int, instructionText: String)]) {
        do {
            var stepCounter = instructionsList.count + 1
            
            for instruction in instructionsList {
                try db?.run(instructions.insert(self.recipeId <- recipeId, self.stepNumber <- stepCounter, self.instructionText <- instruction.instructionText))
                stepCounter += 1
            }
            print("Instructions added successfully!")
        } catch {
            print("Error adding instructions: \(error)")
        }
    }

    func deleteInstruction(recipeId: Int64, stepNumber: Int) {
        do {
            let query = instructions.filter(self.recipeId == recipeId && self.stepNumber == stepNumber)
            try db?.run(query.delete())
            updateStepNumbers(recipeId: recipeId)
        } catch {
            print("Error deleting instruction: \(error)")
        }
    }

    func fetchInstructions(recipeId: Int64) -> [(stepNumber: Int, instructionText: String)] {
        var instructionList: [(stepNumber: Int, instructionText: String)] = []
        do {
            let query = instructions.filter(self.recipeId == recipeId).order(self.stepNumber)
            for instruction in try db!.prepare(query) {
                instructionList.append((instruction[self.stepNumber], instruction[self.instructionText]))
            }
        } catch {
            print("Error fetching instructions: \(error)")
        }
        return instructionList
    }

    func updateStepNumbers(recipeId: Int64) {
        let instructionsList = fetchInstructions(recipeId: recipeId)
        do {
            try db?.run(instructions.filter(self.recipeId == recipeId).delete()) // Remove existing instructions for this recipe
            var stepCounter = 1
            for instruction in instructionsList {
                try db?.run(instructions.insert(self.recipeId <- recipeId, self.stepNumber <- stepCounter, self.instructionText <- instruction.instructionText))
                stepCounter += 1
            }
        } catch {
            print("Error updating step numbers: \(error)")
        }
    }
}
