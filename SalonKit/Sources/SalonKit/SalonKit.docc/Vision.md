# Vision

What the apps are for, and which API surface each feature will ride.

Two apps: the customer's own salon app and the staff's day on a phone. The
aggregator is the direction — key custody and routing belong on a server — but
the white-label app is the honest client this API was written for, and it comes
first. The prose and the reasons are in `Positioning.md` at the repository
root; this article is the map from it to the operations the `Salon1cAPI`
package exposes (the package's own catalog is authoritative for wire
behaviour).

## Capability map

| Feature | Operations | App | Phase |
|---|---|---|---|
| Sign in through the salon's channels (SMS, WhatsApp, call, Telegram bot) | `getAuthTypes`, `authorize`, `requestPhoneConfirmation`, `getClientToken`, `checkUserToken` | Book | 1 |
| Book: services → masters → dates → slots → cost → confirm | `getBookableServices`, `getBookableStaff`, `getBookableDates`, `getBookableTimes`, `getRecordCost`, `bookVisit` | Book | 1 |
| My visits: upcoming, past, reschedule, cancel; local reminders | `getClientPlannedVisits`, `getClientVisitHistory`, `rescheduleVisit`, `cancelVisit`, `getRecordingDates` | Book | 1 |
| Salon card: branches, hours, contacts, services | `getSalons`, `getServices` | Book | scaffold shows the list |
| Profile | `getClientInfo`, `updateClientById`, `updateClientProfile` | Book | 2 |
| Balance and statement, top-up; packages; certificates | `getClientAccounts`, `getDepositMovements`, `refillDeposit`, `getClientTickets`, `getClientTicket`, `getClientCertificates` | Book | 2 |
| Rate a visit; read the salon's ratings | `rateVisit`, `getComments` | Book | 2 |
| Shop: catalogue, groups, filters, cart, delivery, pay, orders, legal texts | `getPriceList`, `getProductGroups`, `getProductFilters`, `getCartCost`, `getDeliveryOptions`, `payOrder`, `cancelPayment`, `getOrders`, `getOrderStatuses`, `getStoreContacts`, `getPublicOffer`, `getPrivacyPolicy` | Book | 3 |
| Today's records; find or create a client; edit a record | `getRecordsList`, `getVisits`, `getFinishedVisits`, `searchClients`, `createClient`, `findClientByPhone`, `updateRecord` | Desk | D1 |
| Take a sale, send a payment link, settle a debt | `createSale`, `updateSale`, `cancelSale`, `createPaymentLink`, `getDebtVisits`, `payVisit` | Desk | D1 |
| A master's work schedule | `getStaffWorkSchedule`, `updateStaffWorkSchedule` | Desk | D2 |
| Trusted-integration sign-in (signature) | `authorizeWithSignature` | server | aggregator |
| Self-service terminal (v2) | `authorizeTerminal`, `getTerminalStaff`, `getTerminalServices`, `getTerminalCartCost`, `payTerminal` | — | not planned |

62 operations in total.

## Sync and notifications

The API offers no webhooks, so freshness is poll-and-compare: each surface
re-fetches on appearance and on an interval its controller owns. Visit
reminders are local notifications — the app booked the visit, so it knows when
to fire. "Something changed at the salon → push to staff" needs a relay, and
the relay that holds keys is the aggregator — Later, and a server project.

## What the apps will not do

No vendor branding — this is the salon's own app, not a 1С showcase. No raw API
vocabulary in the UI — the UI says visit, booking, master, service, balance,
package, certificate; never record, ticket, deposit, usertoken, parameters
(CLAUDE.md rule 13). No marketplace before the server exists.
