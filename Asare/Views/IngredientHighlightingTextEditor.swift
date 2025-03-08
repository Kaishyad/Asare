import SwiftUI

struct IngredientHighlightingTextEditor: View {
    @Binding var instructionText: String
    var ingredients: [String] // List of ingredient names to detect

    var body: some View {
        VStack {
            Text("Instruction:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            RichTextView(text: instructionText, ingredients: ingredients)
                .frame(height: 150)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
        }
    }
}

struct RichTextView: View {
    var text: String
    var ingredients: [String]

    var body: some View {
        Text(buildAttributedText())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func buildAttributedText() -> AttributedString {
        var attributedText = AttributedString(text)
        
        for ingredient in ingredients {
            if let range = attributedText.range(of: ingredient, options: .caseInsensitive) {
                attributedText[range].font = .bold()
                attributedText[range].foregroundColor = .pink
            }
        }
        
        return attributedText
    }
}
