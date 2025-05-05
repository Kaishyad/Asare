import SwiftUI

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
    @EnvironmentObject var settings: AppSettings

    @Binding var instructions: [(stepNumber: Int, instructionText: String)]
    @State private var newInstruction: String = ""
    @State private var editingStepNumber: Int? = nil
    @State private var editedInstructionText: String = ""
    @State private var isPopoverPresented = false
    @State private var selectedInstruction: Instruction? = nil
    @State private var showNewestFirst: Bool = false

    var body: some View {
        VStack {
            Text("Add Instructions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .accessibilityAddTraits(.isHeader)


            TextEditor(text: $newInstruction)
                .frame(height: 150)
                .padding()
                .background(Color(uiColor: .systemBackground))
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
            .accessibilityAddTraits(.isButton)


            Toggle(isOn: $showNewestFirst) {
                Text("Reverse Step Order")
                    .font(.headline)
                    .foregroundColor(.pink)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .toggleStyle(SwitchToggleStyle(tint: .pink))
            .accessibilityAddTraits(.isToggle)
            .padding(.horizontal)


                        if instructions.isEmpty {
                            Text("No instructions added yet.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                                    ForEach((showNewestFirst ? instructions.reversed() : instructions).map { Instruction(stepNumber: $0.stepNumber, instructionText: $0.instructionText) }, id: \.id) { instruction in
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
                    HStack {
                                    Spacer()
                                    Button("Done") {
                                        resetEditingState()
                                    }
                                    .padding()
                                    .foregroundColor(.pink)
                                    .accessibilityAddTraits(.isButton)

                                }
                    
                    Text("Edit Instruction")
                        .font(.title2)
                        .padding()

                    TextEditor(text: $editedInstructionText)
                        .frame(height: 150)
                        .padding()
                        .background(Color(uiColor: .systemBackground))
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
                    .accessibilityAddTraits(.isButton)

                }
                .padding()
            }
        }
        .onChange(of: selectedInstruction) { _ in
            isPopoverPresented = selectedInstruction != nil
        }
        .background(Color(uiColor: .secondarySystemBackground))

    }

    private func addInstruction() {
        let newStepNumber = instructions.count + 1
        instructions.append((stepNumber: newStepNumber, instructionText: newInstruction))
        newInstruction = ""
        updateStepNumbers()
    }

    private func editInstruction(_ instruction: Instruction) {
        selectedInstruction = instruction
        editedInstructionText = instruction.instructionText
        isPopoverPresented = true
    }

    private func updateInstruction(stepNumber: Int) {
        if let index = instructions.firstIndex(where: { $0.stepNumber == stepNumber }) {
            instructions[index].instructionText = editedInstructionText
            resetEditingState()
            updateStepNumbers()
        }
    }

    private func deleteInstruction(stepNumber: Int) {
        instructions.removeAll { $0.stepNumber == stepNumber }
        updateStepNumbers()
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
            Text(instruction.instructionText)
                .font(.body)
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
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(height: 120)
    }
}
