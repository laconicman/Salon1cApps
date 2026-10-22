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

/// Sleeps past any reasonable reload, so a cancelled first request throws
/// `CancellationError` (from `Task.sleep`) rather than answering stale data.
private struct SleepingTransport: ClientTransport {
    func send(_ request: HTTPRequest, body requestBody: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        try await Task.sleep(for: .seconds(5))
        return (HTTPResponse(status: .ok), HTTPBody("{}"))
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
        try controller(transport: StubTransport(body: body))
    }

    private func controller(transport: any ClientTransport) throws -> SalonController {
        SalonController(
            configuration: Self.configuration,
            client: try SalonClient.make(
                configuration: Self.configuration,
                transport: transport
            )
        )
    }

    @Test("the vendor's example body loads one salon")
    func loaded() async throws {
        let controller = try controller(body: """
            {"Parameters":[{"id":"0d190fc8","title":"OOO \\"Салон красоты\\"","work_time":[{"active":true,"day":1,"start":"07:00","end":"22:00"}],"contact_information":{"phone":"78945612233","email":"test_salon@mail.ru","address":"г.Москва","website":"www.website.ru"}}],"Errors":{"code":0,"message":""}}
            """)
        await controller.reload().value
        #expect(controller.phase == .loaded([
            Salon(id: "0d190fc8", title: "OOO \"Салон красоты\"", phone: "78945612233", email: "test_salon@mail.ru", address: "г.Москва", website: "www.website.ru")
        ]))
    }

    @Test("a domain refusal ends in .failed with the refusal text")
    func failed() async throws {
        let controller = try controller(body: """
            {"Parameters":[],"Errors":{"code":1000,"message":"Ошибка работы с базой данных."}}
            """)
        await controller.reload().value
        guard case .failed(let text) = controller.phase else {
            Issue.record("expected .failed, got \(controller.phase)")
            return
        }
        #expect(text.contains("1000"))
    }

    @Test("a reload cancels the request in flight")
    func reloadCancelsInFlight() async throws {
        // The first load sleeps; reload() must cancel it so its CancellationError
        // is swallowed, then the second load's body wins.
        let controller = try controller(transport: SleepingThenStubTransport())
        _ = controller.reload()
        let second = controller.reload()
        await second.value
        #expect(controller.phase == .loaded([
            Salon(id: "0d190fc8", title: "OOO \"Салон красоты\"", phone: "78945612233", email: "test_salon@mail.ru", address: "г.Москва", website: "www.website.ru")
        ]))
    }
}

/// Answers like `SleepingTransport` once, then like `StubTransport` — the two
/// transports a double-`reload` exercises in one client.
private struct SleepingThenStubTransport: ClientTransport {
    let calls = Counter()

    actor Counter {
        private var value = 0
        func next() -> Int {
            defer { value += 1 }
            return value
        }
    }

    func send(_ request: HTTPRequest, body requestBody: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        if await calls.next() == 0 {
            try await Task.sleep(for: .seconds(5))
        }
        return (HTTPResponse(status: .ok), HTTPBody("""
            {"Parameters":[{"id":"0d190fc8","title":"OOO \\"Салон красоты\\"","work_time":[{"active":true,"day":1,"start":"07:00","end":"22:00"}],"contact_information":{"phone":"78945612233","email":"test_salon@mail.ru","address":"г.Москва","website":"www.website.ru"}}],"Errors":{"code":0,"message":""}}
            """))
    }
}
