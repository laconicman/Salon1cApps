import Foundation
import Salon1cAPI

/// A salon as the app sees it — generated wire types stop at the controller
/// boundary (rule 1), so views only ever meet this struct.
public struct Salon: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let phone: String?
    public let email: String?
    public let address: String?
    public let website: String?

    public init(
        id: String,
        title: String,
        phone: String? = nil,
        email: String? = nil,
        address: String? = nil,
        website: String? = nil
    ) {
        self.id = id
        self.title = title
        self.phone = phone
        self.email = email
        self.address = address
        self.website = website
    }

    /// Maps the generated `getSalons` element. `nil` when the wire element has no
    /// `id` or no `title` — an identity-less salon cannot be shown or chosen.
    /// Contact fields come from `contact_information` (the vendor's example uses
    /// the nested object).
    public init?(_ wire: Operations.GetSalons.Output.Ok.Body.JsonPayload.ParametersPayload.Element) {
        guard let id = wire.id, let title = wire.title else { return nil }
        self.init(
            id: id,
            title: title,
            phone: wire.contactInformation?.phone,
            email: wire.contactInformation?.email,
            address: wire.contactInformation?.address,
            website: wire.contactInformation?.website
        )
    }
}
