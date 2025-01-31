import SwiftUI

struct ViewRecipesPage: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        VStack {
            Text("📖 All Recipes")
                .font(settings.font)
                .padding()
                .accessibilityLabel("View all saved recipes")
            Spacer()
        }
        .navigationTitle("Recipes")
    }
}

#Preview {
    ViewRecipesPage().environmentObject(AppSettings())
}
