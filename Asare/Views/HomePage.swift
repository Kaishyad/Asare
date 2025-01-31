import SwiftUI

struct HomePage: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        VStack {
            Text("Welcome to the Recipe App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Text("Enjoy browsing and creating recipes!")
                .font(settings.font)
                .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomePage()
}
