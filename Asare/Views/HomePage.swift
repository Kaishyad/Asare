import SwiftUI

struct HomePage: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        VStack {
            Text("Asare")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal)
            
            Text("Enjoy browsing and creating recipes!")
                .font(.system(size: 25, weight: .bold))
                .fontWeight(.bold)
                .foregroundColor(.pink)
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)

            HStack {
                    Text("Favorites")
                        .font(settings.font)
                        .bold()
                    Spacer()
                }

            Spacer()
            
            
            
        }
        .padding()
    }
}

