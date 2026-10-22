import Foundation
import Testing
@testable import SalonKit

@Suite("Salon configuration")
struct SalonConfigurationTests {
    private static let serverURLString = "http://private-anon-5309c9fb20-salon1c.apiary-mock.com/api"

    private static func dictionary(
        salonID: String? = "0d190fc8",
        apiKey: String? = "mock",
        serverURL: String? = serverURLString
    ) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let salonID { dictionary["SalonID"] = salonID }
        if let apiKey { dictionary["SalonAPIKey"] = apiKey }
        if let serverURL { dictionary["SalonServerURL"] = serverURL }
        return dictionary
    }

    @Test("all three keys read through")
    func readsAllKeys() throws {
        let configuration = try SalonConfiguration(info: Self.dictionary())
        #expect(configuration.salonID == "0d190fc8")
        #expect(configuration.apiKey == "mock")
        #expect(configuration.serverURL.absoluteString == Self.serverURLString)
    }

    @Test("an absent key throws .missing")
    func missingKey() {
        #expect(throws: SalonConfigurationError.missing(key: "SalonAPIKey")) {
            try SalonConfiguration(info: Self.dictionary(apiKey: nil))
        }
    }

    @Test("an empty value counts as missing")
    func emptyKey() {
        #expect(throws: SalonConfigurationError.missing(key: "SalonID")) {
            try SalonConfiguration(info: Self.dictionary(salonID: ""))
        }
    }

    @Test("an unparseable URL throws .invalidURL")
    func invalidURL() {
        #expect(throws: SalonConfigurationError.invalidURL("ht tp://nope")) {
            try SalonConfiguration(info: Self.dictionary(serverURL: "ht tp://nope"))
        }
    }
}
