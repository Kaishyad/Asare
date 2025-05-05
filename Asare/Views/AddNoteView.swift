import SwiftUI

struct AddNoteView: View {
    @EnvironmentObject var settings: AppSettings
    @Binding var recipeNote: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Recipe Note")
                    .font(settings.largeTitleFont)
                    .foregroundColor(.pink)
                    .padding()
                    .accessibilityAddTraits(.isHeader)

                
                ZStack {
                    Color.white.opacity(0.1)
                        .cornerRadius(10)
                        .shadow(radius: 10)

                    TextEditor(text: $recipeNote)
                        .font(settings.font)
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .frame(minHeight: 200)
                }
                .padding(.horizontal)

                // Save Notes Button
                Button(action: {
                    // Save and dismiss
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Note")
                        .font(settings.font.bold())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                }
                .accessibilityAddTraits(.isButton)

                Spacer()
            }
            .padding(.top, 10)
            .background(Color(uiColor: .systemBackground))
           
        }
    }
}
