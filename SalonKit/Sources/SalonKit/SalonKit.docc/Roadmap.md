# Roadmap

Planned work, in priority order.

## Now — the scaffold

Two app targets, a kit that owns the wire, and a hello-wire: SalonBook lists
the salon from the vendor's Apiary mock over real HTTP, proving
xcconfig → Info.plist → `SalonConfiguration` → `payload()` end to end.
SalonDesk is an honest placeholder.

## Next — the SalonBook slice

Sign-in through the salon's channels first — the `authorize` `oneOf` flow is
hand-shaped in the kit (package TD-10 / SA-5) — then services → masters →
dates → slots → cost → book → my visits (upcoming/past, reschedule, cancel) →
local reminders, per the Vision map. Russian UI strings land after the first
slice — source stays English, catalogs translate.

## Then — the SalonDesk slice

Today's records → find/create client → sale → payment link. Blocked on
**SA-3**: whose token the staff operations accept is undocumented, and Desk's
auth design waits on a live call.

## Later — maybe

The aggregator server (key custody, routing, staff push relay — SA-6), the
shop surface, loyalty surfaces. `Positioning.md` argues why the aggregator is
a server project and why white-label comes first.
