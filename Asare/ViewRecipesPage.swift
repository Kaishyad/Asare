import SwiftUI

struct ViewRecipesPage: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        VStack {
            Text("📖 All Recipes")
                .font(settings.font)
                .padding()
            Spacer()
        }
        .navigationTitle("Recipes")
    }
}

#Preview {
    ViewRecipesPage().environmentObject(AppSettings())
}
