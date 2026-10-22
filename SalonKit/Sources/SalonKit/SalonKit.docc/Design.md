# Design

Every load-bearing decision, with the alternative that was rejected.

## D1 — One repo, two app targets, one local kit

`Salon1cApps` carries SalonBook and SalonDesk as two targets of one XcodeGen
project; the code they share is `SalonKit`, a local SwiftPM package consumed by
path.

**Rejected:** two repos plus a third kit repo — the YDelivery/YDeliveryKit
ceremony without a second consumer for the kit yet. The seam that matters is
the *package boundary*, not the repository boundary; the kit can be extracted
the day it earns one.

## D2 — XcodeGen generates the project; pbxproj is untracked

`project.yml` is the source of truth; `xcodegen generate` produces
`Salon1cApps.xcodeproj`, whose `project.pbxproj` and generated schemes are
gitignored while `Package.resolved` stays tracked so pins survive regeneration.

**Rejected:** a JSON project format — verified absent: Xcode 27.0 (27A266a)
`xcodebuild -convert-project "Xcode 27.0"` still writes a classic
`project.pbxproj` (objectVersion 110). **Rejected:** committing a hand-made
pbxproj — the structured-files rule.

## D3 — The API package by URL, pinned in two places

`SalonKit/Package.swift` declares `Salon1c` at `.upToNextMinor(from: "0.3.1")`,
and `project.yml` declares it again at `minorVersion: 0.3.1`. The pins move
together — rule 9. The manifests are authoritative for the number; this
article records the *rule* — both pins, same tag.

**Rejected:** a path dependency — a clean clone must prove the published
product builds. **Rejected:** `from:` — 0.x minors break.

## D4 — The salon is configuration, not a constant

Committed `Salon.xcconfig` with mock defaults → optional gitignored
`Salon.local.xcconfig` → `SalonBook-Info.plist` → ``SalonConfiguration``. The
API key travels as build configuration because *every* call needs it — the
vendor's own model for client apps. User tokens are a different kind of secret
and will live in the Keychain when sign-in lands.

**Rejected:** constants in Swift — that is a fork, not a configuration.
**Rejected:** a Keychain-provisioned setup screen — right for user tokens,
wrong for a build-time identity; the aggregator will replace the *source* of
configuration, not the type.

## D5 — Direction docs live in the kit's catalog

Two apps share one direction, so the DocC catalog lives inside `SalonKit` —
one place to read it, versioned with the code both apps share.

**Rejected:** a catalog per app — the direction would fork on day one.

## D6 — iOS 17 floor, Swift 6 language mode, MainActor by default

iOS 17 is the package's floor, so no `@available` exists anywhere. App targets
run `SWIFT_DEFAULT_ACTOR_ISOLATION MainActor` with Approachable Concurrency;
SwiftPM packages — the kit and the API package alike — keep SwiftPM's own
default, because the app-level build setting never reaches them, so the
generated client stays nonisolated (YDelivery's Design — "The floor is iOS 17,
in Swift 6 language mode" — is the precedent).

## D7 — Generated types stop at the controller boundary

Views see app models (``Salon``), never `Components.Schemas.*`; controllers may
hold the generated `Client` and use `.payload()` — the call shape — and the kit
maps wire → models. Generated `Output` enums reach the app only where a screen
needs the exact status.

**Rejected:** views on `Components.Schemas.*` as the demo app does — showing
the wire raw is the demo's job, not a product's.

## D8 — Mock by default

The committed `Salon.xcconfig` points at the vendor's Apiary mock, so a clean
clone runs end to end over real HTTP against the documented examples.

**Rejected:** a demo transport in the app — the mock already is one, over real
HTTP; a fake transport would hide the wire rather than exercise it.
