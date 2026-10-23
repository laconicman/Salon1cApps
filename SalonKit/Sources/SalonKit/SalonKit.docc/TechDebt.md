# Tech Debt

The numbered register. Each entry names its Cost (what it costs us today) and
Discharge (what makes it go away). Code references items as `SA-n`.

## SA-1 — Plain-HTTP API base, ATS exceptions carried

The vendor's documented host `http://cloud.salon1c.ru/api` and the Apiary mock
are both plain HTTP, so SalonBook carries `NSAppTransportSecurity` exceptions
for `apiary-mock.com` and `cloud.salon1c.ru`.

**Cost:** traffic to the salon API is unencrypted — including the `apikey`
header; acceptable against the mock, wrong to ship against a real host
unverified.
**Discharge:** confirm `https` on a real deployment, flip the default, drop the
exceptions.

## SA-2 — No live credential yet

Every behaviour is verified against the vendor's Apiary mock and the documented
examples only — mirrors the package's TD-1.

**Cost:** anything the document gets wrong (and the mock faithfully replays) is
unverified.
**Discharge:** a real `apikey`/`salon_id` in `Salon.local.xcconfig`; wire
captures replace mock assumptions feature by feature.

## SA-3 — Staff-side token semantics unknown

Whose token the staff operations (records list, sales, client search, schedule)
accept is undocumented — a staff `usertoken`, the `apikey` alone, or a third
credential. `authorizeWithSignature` may be the intended path.

**Cost:** SalonDesk's auth cannot be designed from documentation; a guess
builds the wrong gate.
**Discharge:** one live call against a real salon settles the header set; the
Desk slice starts there.

## SA-4 — The project file is generated

`Salon1cApps.xcodeproj` is XcodeGen output and gitignored; `project.yml` is the
source of truth (YD-4 precedent in YDelivery).

**Cost:** a fresh clone does not open until `xcodegen generate` runs.
**Discharge:** none wanted — the alternative (committed pbxproj) is the defect.

## SA-5 — The `authorize` oneOf is not unwrapped by the facade

The package's `payload()` skips `authorize` deliberately (its two outcomes —
"code sent" vs "token issued" — cannot share a payload type; package TD-10).

**Cost:** sign-in must shape the oneOf envelope by hand in the kit.
**Discharge:** the Book sign-in slice lands it — one screen's worth of mapping,
not a framework problem.

## SA-6 — Push relay undesigned

No webhooks in the API; staff-side changes reach the customer app only by
polling (Vision → "Sync and notifications").

**Cost:** no real-time updates; reminders are local-only until a relay exists.
**Discharge:** the aggregator-era relay — a server project by design.

## SA-7 — `Salon.work_time` not mapped

The wire's `work_time` array is dropped in `Salon.init?` — the scaffold shows
title and contacts only.

**Cost:** opening hours cannot render yet.
**Discharge:** the first slice that shows hours maps it — `day`/`start`/`end`
are `HH:mm` strings and wire day numbers; formatting is that slice's job.

## SA-8 — SalonKit works around OSLogLoggingMiddleware's manifest

**Discharged 2026-10-24** by OSLogLoggingMiddleware 1.1.1
(laconicman/OSLogLoggingMiddleware#1, declares `OpenAPIRuntime`) and
Salon1c 0.3.3 (laconicman/Salon1c#20, the follow-up `HTTPTypes` declaration the
discharge build itself proved missing). Evidence: the two-consumer
`xcodebuild build-for-testing` — app and test bundle both linking `Salon1cAPI`,
which Xcode builds as a dynamic package framework — fails to link at 0.3.1/1.1.0
(undefined `OpenAPIRuntime` symbols in `OSLogLoggingMiddleware`, then
`HTTPTypes` in `Salon1cAPI`) and succeeds at 0.3.3/1.1.1. The wiring landed with
the discharge: `.static` and `@_exported` are gone and app/test targets link
`Salon1cAPI` directly.

The upstream package (`laconicman/OSLogLoggingMiddleware` 1.1.0) imports
`OpenAPIRuntime` without declaring the `swift-openapi-runtime` product in its
target dependencies — it links statically, but not as a dynamic package
framework, which is what Xcode builds when a product has two consumers. Three
workarounds here depend on it: `SalonKit` is a `.static` product
(`SalonKit/Package.swift`), `SalonClient.swift` `@_exported import Salon1cAPI`,
and no app target links `Salon1cAPI` directly (`project.yml`).

**Cost:** `@_exported` hands every app file the whole generated module without
an explicit import — rule 1 holds by review, not by the compiler; a second kit
consumer must stay static.
**Discharge:** fix the upstream manifest (declare `OpenAPIRuntime`), tag it,
bump the pin through `Salon1c`; then drop `.static` and `@_exported` and link
`Salon1cAPI` from the app targets as YDelivery links its package.
