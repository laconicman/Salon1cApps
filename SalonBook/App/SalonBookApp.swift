import SwiftUI
import SalonKit

/// The composition root, and nothing else: the controller is created once and
/// injected into the tree (rule 4 — no singletons). A misconfigured build is a
/// rendered state, not a trap (rule 5).
@main
struct SalonBookApp: App {
    private let root: Result<SalonController, any Error>

    init() {
        root = Result {
            let configuration = try SalonConfiguration()
            return SalonController(
                configuration: configuration,
                client: try SalonClient.make(configuration: configuration)
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            switch root {
            case .success(let controller):
                RootView()
                    .environment(controller)
            case .failure(let error):
                UnconfiguredView(error: error)
            }
        }
    }
}
