import Foundation
import OpenAPIRuntime
import HTTPTypes

#if DEBUG
/// Answers the vendor's documented `getSalons` example so `#Preview`s render
/// real data without a network — the same canned body the tests use.
struct PreviewTransport: ClientTransport {
    func send(_ request: HTTPRequest, body requestBody: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody("""
            {"Parameters":[{"id":"0d190fc8","title":"OOO \\"Салон красоты\\"","work_time":[{"active":true,"day":1,"start":"07:00","end":"22:00"}],"contact_information":{"phone":"78945612233","email":"test_salon@mail.ru","address":"г.Москва","website":"www.website.ru"}}],"Errors":{"code":0,"message":""}}
            """))
    }
}
#endif
