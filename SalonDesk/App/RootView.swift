import SwiftUI

struct RootView: View {
    var body: some View {
        ContentUnavailableView(
            "SalonDesk",
            systemImage: "person.badge.clock",
            description: Text("The staff app. Nothing here yet — see the Roadmap.")
        )
    }
}

#Preview {
    RootView()
}
