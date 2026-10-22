import SwiftUI
import SalonKit

/// The build has no usable salon configuration — `Salon.xcconfig` chain broke
/// before a controller could be created. Shows the error's own description.
struct UnconfiguredView: View {
    let error: any Error

    var body: some View {
        ContentUnavailableView(
            "SalonBook is not configured",
            systemImage: "gearshape",
            description: Text(error.localizedDescription)
        )
    }
}

#Preview {
    UnconfiguredView(error: SalonConfigurationError.missing(key: "SalonAPIKey"))
}
