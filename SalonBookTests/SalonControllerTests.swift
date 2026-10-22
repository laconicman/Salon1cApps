import Foundation
import Testing
import SalonKit
import Salon1cAPI
import OpenAPIRuntime
import HTTPTypes
@testable import SalonBook

/// A canned-response transport — the seam `SalonClient.make(transport:)` exists
/// for. The controller's tests never touch a network.
private struct StubTransport: ClientTransport {
    let body: String

    func send(_ request: HTTPRequest, body requestBody: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        (HTTPResponse(status: .ok), HTTPBody(body))
    }
}

/// The controller's only logic is the state machine around the call — tests
/// drive it with a stub transport, never a bundle or a network.
@Suite("Salon controller")
@MainActor
struct SalonControllerTests {
    private static let configuration = SalonConfiguration(
        salonID: "0d190fc8",
        apiKey: "mock",
        serverURL: URL(string: "http://example.invalid/api")!
    )

    private func controller(body: String) throws -> SalonController {
        SalonController(
            configuration: Self.configuration,
            client: try SalonClient.make(
                configuration: Self.configuration,
                transport: StubTransport(body: body)
            )
        )
    }

    @Test("the vendor's example body loads one salon")
    func loaded() async throws {
        let controller = try controller(body: """
            {"Parameters":[{"id":"0d190fc8","title":"OOO \\"Салон красоты\\"","work_time":[{"active":true,"day":1,"start":"07:00","end":"22:00"}],"contact_information":{"phone":"78945612233","email":"test_salon@mail.ru","address":"г.Москва","website":"www.website.ru"}}],"Errors":{"code":0,"message":""}}
            """)
        await controller.load()
        #expect(controller.phase == .loaded([
            Salon(id: "0d190fc8", title: "OOO \"Салон красоты\"", phone: "78945612233", email: "test_salon@mail.ru", address: "г.Москва", website: "www.website.ru")
        ]))
    }

    @Test("a domain refusal ends in .failed with the refusal text")
    func failed() async throws {
        let controller = try controller(body: """
            {"Parameters":[],"Errors":{"code":1000,"message":"Ошибка работы с базой данных."}}
            """)
        await controller.load()
        guard case .failed(let text) = controller.phase else {
            Issue.record("expected .failed, got \(controller.phase)")
            return
        }
        #expect(text.contains("1000"))
    }
}
