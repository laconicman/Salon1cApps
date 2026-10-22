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
    @ObservationIgnored private var loading: Task<Void, Never>?

    init(configuration: SalonConfiguration, client: Client) {
        self.configuration = configuration
        self.client = client
    }

    /// Starts the load, cancelling one already in flight — the controller owns
    /// the task (rule 8); tests await the returned handle.
    @discardableResult
    func reload() -> Task<Void, Never> {
        loading?.cancel()
        let task = Task { await fetch() }
        loading = task
        return task
    }

    /// A superseded request never writes `phase`, whichever way it ends —
    /// success or failure.
    private func fetch() async {
        phase = .loading
        do {
            let salons = try await client
                .getSalons(path: .init(salonId: configuration.salonID))
                .payload()
                .compactMap(Salon.init)
            guard !Task.isCancelled else { return }
            phase = .loaded(salons)
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed(error.localizedDescription)
        }
    }
}
