import Foundation

/// The salon this build serves — the white-label dial.
///
/// Filled by `SalonBook-Info.plist` from `Salon.xcconfig`, read back here through the
/// bundle's `infoDictionary`. Committed defaults point at the vendor's Apiary mock; a
/// gitignored `Salon.local.xcconfig` carries a real salon's values (TechDebt → SA-2).
public struct SalonConfiguration: Sendable, Equatable {
    /// The `{salon_id}` path parameter every v1 call carries.
    public let salonID: String
    /// The `apikey` header — the vendor's credential model for client-side apps.
    public let apiKey: String
    /// The API base URL — `http://cloud.salon1c.ru/api` on the real host, the Apiary
    /// mock in a clean clone.
    public let serverURL: URL

    public init(salonID: String, apiKey: String, serverURL: URL) {
        self.salonID = salonID
        self.apiKey = apiKey
        self.serverURL = serverURL
    }

    /// Reads `SalonID`, `SalonAPIKey`, `SalonServerURL` — the keys
    /// `SalonBook-Info.plist` fills from `Salon.xcconfig`. An absent **or empty**
    /// value is `.missing`; an unparseable URL is `.invalidURL`.
    public init(bundle: Bundle = .main) throws(SalonConfigurationError) {
        try self.init(info: bundle.infoDictionary ?? [:])
    }

    /// The test seam — `init(bundle:)` forwards here; tests drive a literal
    /// dictionary rather than subclassing `Bundle`.
    init(info: [String: Any]) throws(SalonConfigurationError) {
        func string(_ key: String) throws(SalonConfigurationError) -> String {
            guard let value = info[key] as? String, !value.isEmpty else {
                throw .missing(key: key)
            }
            return value
        }
        let urlString = try string("SalonServerURL")
        guard let url = URL(string: urlString) else {
            throw .invalidURL(urlString)
        }
        self.init(
            salonID: try string("SalonID"),
            apiKey: try string("SalonAPIKey"),
            serverURL: url
        )
    }
}

/// What `SalonConfiguration(bundle:)` can throw — `LocalizedError` so the
/// unconfigured screen shows it as is.
public enum SalonConfigurationError: LocalizedError, Equatable {
    /// A required key is absent or empty in the InfoDictionary.
    case missing(key: String)
    /// `SalonServerURL` did not parse as a URL.
    case invalidURL(String)

    public var errorDescription: String? {
        switch self {
        case .missing(let key):
            "Salon configuration is missing '\(key)' — expected it in Info.plist, filled by Salon.xcconfig or a gitignored Salon.local.xcconfig."
        case .invalidURL(let value):
            "SalonServerURL '\(value)' is not a valid URL — check Salon.xcconfig or Salon.local.xcconfig."
        }
    }
}
