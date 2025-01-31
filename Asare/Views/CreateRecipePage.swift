import SwiftUI

struct CreateRecipePage: View {
    @EnvironmentObject var settings: AppSettings
    @State private var recipeName: String = ""

    var body: some View {
        VStack {
            Text("➕ Create New Recipe")
                .font(settings.font)
                .padding()
                .accessibilityLabel("Create a new recipe")

            TextField("Enter Recipe Name", text: $recipeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(settings.font)
                .padding()
                .accessibilityLabel("Enter the name of your recipe")

            Button(action: {
                settings.triggerHaptic()
                print("Recipe Saved: \(recipeName)")
            }) {
                Text("Save Recipe")
                    .font(settings.font)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .navigationTitle("New Recipe")
        .padding()
    }
}

#Preview {
    CreateRecipePage().environmentObject(AppSettings())
}
