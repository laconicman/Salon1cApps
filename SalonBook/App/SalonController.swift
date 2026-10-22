import Foundation
import SalonKit
import Salon1cAPI

/// Owns the salon list's lifecycle. Views see `Phase` and app models, never the
/// wire — rule 1: generated types stop at the controller boundary.
@Observable @MainActor
final class SalonController {
    enum Phase: Equatable {
        case loading
        case loaded([Salon])
        /// `localizedDescription` — a properly filled error is displayed as is.
        case failed(String)
    }

    private(set) var phase: Phase = .loading
    let configuration: SalonConfiguration
    private let client: Client

    init(configuration: SalonConfiguration, client: Client) {
        self.configuration = configuration
        self.client = client
    }

    func load() async {
        phase = .loading
        do {
            let salons = try await client
                .getSalons(path: .init(salonId: configuration.salonID))
                .payload()
                .compactMap(Salon.init)
            phase = .loaded(salons)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
