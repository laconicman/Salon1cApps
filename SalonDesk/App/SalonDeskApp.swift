import SwiftUI
import SalonKit

/// The staff app's composition root — a placeholder today (Roadmap → SalonDesk
/// slice, blocked on SA-3), injected the same way SalonBook's will be.
@main
struct SalonDeskApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
