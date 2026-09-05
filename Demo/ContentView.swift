import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.965, blue: 0.955)
                .ignoresSafeArea()
            FoxIllustration()
                .aspectRatio(1, contentMode: .fit)
                .padding(12)
        }
    }
}

#Preview {
    ContentView()
}
