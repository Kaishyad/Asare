import SwiftUI

// Define Equatable conformance for the tuple (stepNumber, instructionText)
extension AddInstructionsView {
    struct Instruction: Identifiable, Equatable {
        var id: Int { stepNumber }
        var stepNumber: Int
        var instructionText: String
        
        static func ==(lhs: Instruction, rhs: Instruction) -> Bool {
            return lhs.stepNumber == rhs.stepNumber && lhs.instructionText == rhs.instructionText
        }
    }
}

struct AddInstructionsView: View {
    @Binding var instructions: [(stepNumber: Int, instructionText: String)]  // Binding to update the instructions list
    @State private var newInstruction: String = ""  // Text for adding new instructions
    @State private var editingStepNumber: Int? = nil  // Track the step number being edited
    @State private var editedInstructionText: String = ""  // Text for editing instructions
    @State private var isPopoverPresented = false  // To control the presentation of the popover
    @State private var selectedInstruction: Instruction? = nil  // The instruction to be edited

    var body: some View {
        VStack {
            Text("Add Instructions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Input for new instructions using TextEditor
            TextEditor(text: $newInstruction)
                .frame(height: 150) // Adjust the height to make the text box larger
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)

            Button(action: addInstruction) {
                Text("Add Step")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(newInstruction.isEmpty)
            .padding()

            // Display instructions in a grid layout (one block per row)
            if instructions.isEmpty {
                Text("No instructions added yet.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(instructions.map { Instruction(stepNumber: $0.stepNumber, instructionText: $0.instructionText) }, id: \.id) { instruction in
                            InstructionTile(instruction: instruction, editAction: { editInstruction(instruction) }, deleteAction: { deleteInstruction(stepNumber: instruction.stepNumber) })
                        }
                    }
                    .padding()
                }
            }

            Spacer()
        }
        .padding()
        .popover(isPresented: $isPopoverPresented) {
            if let selectedInstruction = selectedInstruction {
                VStack {
                    Text("Edit Instruction")
                        .font(.title2)
                        .padding()

                    // TextEditor for editing instruction text
                    TextEditor(text: $editedInstructionText)
                        .frame(height: 150) // Adjust height for editing as well
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)

                    Button(action: {
                        updateInstruction(stepNumber: selectedInstruction.stepNumber)
                    }) {
                        Text("Save Changes")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(editedInstructionText.isEmpty)
                    .padding()
                }
                .padding()
            }
        }
        .onChange(of: selectedInstruction) { _ in
            // Ensure the popover is presented whenever the selectedInstruction changes
            isPopoverPresented = selectedInstruction != nil
        }
    }

    private func addInstruction() {
        let newStepNumber = instructions.count + 1
        instructions.append((stepNumber: newStepNumber, instructionText: newInstruction))
        newInstruction = ""
        updateStepNumbers()  // Update step numbers after adding
    }

    private func editInstruction(_ instruction: Instruction) {
        selectedInstruction = instruction
        editedInstructionText = instruction.instructionText
        isPopoverPresented = true // Ensure the popover is shown when editing starts
    }

    private func updateInstruction(stepNumber: Int) {
        if let index = instructions.firstIndex(where: { $0.stepNumber == stepNumber }) {
            instructions[index].instructionText = editedInstructionText
            resetEditingState()
            updateStepNumbers()  // Reorder step numbers
        }
    }

    private func deleteInstruction(stepNumber: Int) {
        instructions.removeAll { $0.stepNumber == stepNumber }
        updateStepNumbers()  // Reorder step numbers after deletion
    }

    private func updateStepNumbers() {
        for (index, _) in instructions.enumerated() {
            instructions[index].stepNumber = index + 1
        }
    }

    private func resetEditingState() {
        selectedInstruction = nil
        editedInstructionText = ""
        isPopoverPresented = false
    }
}

struct InstructionTile: View {
    let instruction: AddInstructionsView.Instruction
    let editAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        VStack {
            Text("Step \(instruction.stepNumber)")
                .font(.headline)
                .foregroundColor(.black)  // Text color changed to black
            Text(instruction.instructionText)
                .font(.body)
                .foregroundColor(.black)  // Text color changed to black
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(.top, 5)

            HStack {
                Spacer()
                Button(action: editAction) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)  // Changed the background to white
        .cornerRadius(10)
        .shadow(radius: 5)  // Added shadow for some depth
        .frame(height: 120)
    }
}
