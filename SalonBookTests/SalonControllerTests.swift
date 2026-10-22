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

/// Holds the first request until released, so the test controls the order in
/// which two in-flight responses land.
private actor Gate {
    private var started: CheckedContinuation<Void, Never>?
    private var release: CheckedContinuation<Void, Never>?
    private var hasStarted = false

    func markStarted() {
        hasStarted = true
        started?.resume()
    }
    func waitUntilStarted() async {
        if hasStarted { return }
        await withCheckedContinuation { started = $0 }
    }
    func hold() async {
        await withCheckedContinuation { release = $0 }
    }
    func open() {
        release?.resume()
    }
}

/// Call 1 answers `stale` only after the gate opens; every later call answers
/// `fresh` at once — deterministic ordering for the supersession test.
private struct GatedTransport: ClientTransport {
    let gate: Gate
    let stale: String
    let fresh: String
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
            await gate.markStarted()
            await gate.hold()
            return (HTTPResponse(status: .ok), HTTPBody(stale))
        }
        return (HTTPResponse(status: .ok), HTTPBody(fresh))
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

    @Test("a superseded request never writes the phase, even when it later succeeds")
    func supersededRequestIsIgnored() async throws {
        let gate = Gate()
        let controller = try controller(transport: GatedTransport(
            gate: gate,
            stale: """
                {"Parameters":[{"id":"0d190fc8","title":"STALE","work_time":[{"active":true,"day":1,"start":"07:00","end":"22:00"}],"contact_information":{"phone":"78945612233","email":"test_salon@mail.ru","address":"г.Москва","website":"www.website.ru"}}],"Errors":{"code":0,"message":""}}
                """,
            fresh: """
                {"Parameters":[{"id":"0d190fc8","title":"OOO \\"Салон красоты\\"","work_time":[{"active":true,"day":1,"start":"07:00","end":"22:00"}],"contact_information":{"phone":"78945612233","email":"test_salon@mail.ru","address":"г.Москва","website":"www.website.ru"}}],"Errors":{"code":0,"message":""}}
                """
        ))
        let first = controller.reload()
        await gate.waitUntilStarted()       // call 1 is in flight, suspended at the gate
        let second = controller.reload()    // cancels task 1
        await second.value
        #expect(controller.phase == .loaded([
            Salon(id: "0d190fc8", title: "OOO \"Салон красоты\"", phone: "78945612233", email: "test_salon@mail.ru", address: "г.Москва", website: "www.website.ru")
        ]))
        await gate.open()                   // the stale response lands on the cancelled task
        await first.value
        #expect(controller.phase == .loaded([
            Salon(id: "0d190fc8", title: "OOO \"Салон красоты\"", phone: "78945612233", email: "test_salon@mail.ru", address: "г.Москва", website: "www.website.ru")
        ]))
    }
}
