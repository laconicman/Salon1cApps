import Foundation
// Re-exported so the apps see `Client`, `Operations` and `.payload()` through
// `import SalonKit` alone — a direct dependency would hit the upstream-manifest
// linking bug (TechDebt → SA-8).
@_exported import Salon1cAPI
import OpenAPIRuntime
import OpenAPIURLSession

/// The kit's one door to the wire: builds the package's `Client` from a
/// `SalonConfiguration`. Controllers call the generated operations on the
/// returned client and use `.payload()` — wire → app-model mapping lives next
/// to the models (`Salon.init?(_:)`).
public enum SalonClient {
    /// - Parameters:
    ///   - configuration: Which salon, under which key, at which base URL.
    ///   - userToken: The signed-in client's `usertoken`, when sign-in lands —
    ///     stored in the Keychain, passed here per call (CLAUDE.md rule 3).
    ///   - transport: The test seam *and* the timeout seam — a stub answers
    ///     canned responses in tests; a `URLSessionTransport(configuration:)`
    ///     carries a tuned request timeout in production. Defaults to
    ///     `URLSessionTransport()`.
    ///
    /// The package's convenience `Client.init(serverURL:credentials:
    /// bodyLoggingConfiguration:transport:)` composes
    /// `OSLogLoggingMiddleware(bodyLoggingConfiguration: .never)` for every
    /// transport — request and response bodies carry personal data and are
    /// never logged.
    public static func make(
        configuration: SalonConfiguration,
        userToken: String? = nil,
        transport: any ClientTransport = URLSessionTransport()
    ) throws -> Client {
        try Client(
            serverURL: configuration.serverURL,
            credentials: Credentials(apiKey: configuration.apiKey, userToken: userToken),
            transport: transport
        )
    }
}
