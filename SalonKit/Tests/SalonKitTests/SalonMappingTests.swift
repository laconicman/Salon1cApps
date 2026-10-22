import Foundation
import Testing
import Salon1cAPI
@testable import SalonKit

@Suite("Wire → app model mapping")
struct SalonMappingTests {
    private typealias Wire = Operations.GetSalons.Output.Ok.Body.JsonPayload.ParametersPayload.Element

    private func element(_ json: String) throws -> Wire {
        try JSONDecoder().decode(Wire.self, from: try #require(json.data(using: .utf8)))
    }

    @Test("the vendor's salons example maps to the app model")
    func salonsMapping() throws {
        // The vendor's own 200 example element for `GET /hs/api/v1/salons/{salon_id}`
        // (openapi.yaml response `example:`).
        let wire = try element(#"""
        {
            "id": "0d190fc8",
            "title": "OOO \"Салон красоты\"",
            "work_time": [
                { "active": true, "day": 1, "start": "07:00", "end": "22:00" }
            ],
            "contact_information": {
                "phone": "78945612233",
                "email": "test_salon@mail.ru",
                "address": "г.Москва",
                "website": "www.website.ru"
            }
        }
        """#)
        let salon = try #require(Salon(wire))
        #expect(salon.id == "0d190fc8")
        #expect(salon.title == "OOO \"Салон красоты\"")
        #expect(salon.phone == "78945612233")
        #expect(salon.email == "test_salon@mail.ru")
        #expect(salon.address == "г.Москва")
        #expect(salon.website == "www.website.ru")
    }

    @Test("an element without id maps to nil")
    func missingID() throws {
        let wire = try element(#"""
        { "title": "Без ID", "work_time": [] }
        """#)
        #expect(Salon(wire) == nil)
    }

    @Test("absent contact_information leaves the contact fields nil")
    func noContactInformation() throws {
        let wire = try element(#"""
        { "id": "x", "title": "Без контактов", "work_time": [] }
        """#)
        let salon = try #require(Salon(wire))
        #expect(salon.phone == nil)
        #expect(salon.email == nil)
        #expect(salon.address == nil)
        #expect(salon.website == nil)
    }
}
