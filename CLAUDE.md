# Salon1cApps — product apps

Two **unofficial** iOS apps on [`Salon1cAPI`](../Salon1c) — **SalonBook** for the
customer and **SalonDesk** for the staff — sharing one direction.
`Positioning.md` argues what the apps are for and why white-label first; the
kit's DocC catalog (`SalonKit/Sources/SalonKit/SalonKit.docc/`) is authoritative
for direction: `Design` (decisions + rejected alternatives) · `Vision`
(capability map) · `Roadmap` (priority order) · `TechDebt` (numbered `SA-n`
register). Render it with
`swift package --package-path SalonKit generate-documentation --target SalonKit`.
The package's own catalog is authoritative for anything about the API itself.

## Architecture

Four-layer MVC per `swiftui-app-structure`: Model → Controller (`@Observable`,
injected via environment) → Root view → Content views. Group by **feature**, not
by role. `SalonKit` owns everything the apps share — app models, configuration,
the client factory.

## Rules specific to this repository

1. **Generated types stop at the controller boundary.** `SalonKit` maps wire →
   app models; `payload()` is the call shape. Generated `Output` enums reach the
   app only where a screen needs the exact status — views never see
   `Components.Schemas.*`.
2. **Two apps, one kit.** Anything both apps need lives in `SalonKit`; app
   targets never import each other.
3. **The salon is configuration, not a constant.** `Salon.xcconfig` →
   `Salon.local.xcconfig` (gitignored) → `SalonBook-Info.plist` →
   `SalonConfiguration`. API keys never land in source or commits; user tokens
   go to the Keychain when sign-in lands.
4. **No singletons.** Controllers are created once in `@main` and injected with
   `.environment(_:)`.
5. **No `try!`, no `fatalError` in app code.** Unconfigured, offline, refused —
   each is a state to render. `Salon1cError` is `LocalizedError`; show
   `localizedDescription`.
6. **Every view gets a `#Preview`, and every `#Preview` must run.** Content views
   take plain values and closures.
7. **`body` declares structure; it never computes presentation.** Formatting in
   extensions on the formatted type; derivation in the view model or controller.
8. **Async work is structured and owned.** Loaders and polling live in
   controllers as cancellable `Task`s — never in views, never fire-and-forget
   without error handling.
9. **Package-first sequencing.** API surface the package lacks starts as a
   `Salon1c` PR (spec patch + tests), tagged and consumed by URL — then the app
   feature. The two `0.3.x` pins (`project.yml`, `SalonKit/Package.swift`) move
   together.
10. **Swift Testing for logic, XCTest only for `XCUIApplication`.** Kit tests:
    `swift test --package-path SalonKit`; app tests through the `SalonBook`
    scheme. Test the pure functions and controllers, not SwiftUI views.
11. **Everything lands via PR.** `main` is protected; Devin Review runs on push
    and `REVIEW.md` steers it. No AI attribution in commits or PRs. Before
    merging, `contrib in laconicman/Salon1cApps --pr N` must read owed 0 /
    to re-read 0. Merges are squash-only; **never wait for CI** — build and test
    locally, read the review round, `gh pr merge N --squash --auto`.
12. **Floor iOS 17.0, Swift 6 language mode**, `MainActor` default isolation on
    app targets, Approachable Concurrency — see Design.
13. **Vocabulary:** the UI says visit, booking, master, service, balance,
    package, certificate — never record, ticket, deposit, usertoken, parameters
    (Positioning's tone note).
14. **`xcodegen generate` after clone** and after editing `project.yml`; the
    pbxproj is not tracked.

## Author's standing preferences

Clarity over brevity. Prefer a vetted SPM when the dependency is smaller than the
problem; say so explicitly when it is not. Cite sources in prose and code
comments. DRY, separation of concerns, low coupling / high cohesion first. Error
types conform to `LocalizedError` with a filled `errorDescription` where they
could ever surface — a properly filled error can be passed around and displayed
as is (author, 2026-09-02). Prefer implicit returns wherever the compiler allows,
including single-expression `switch`/`if` expressions (author, 2026-09-02).

## Related skills

`swiftui-app-structure` · `swiftui-foundations` · `swift-file-organization` ·
`software-development-principles` · `swift-concurrency` · `swift-testing-expert` ·
`apple-swift-openapi-generator` · `atomic-commits` · `git-branching`
