# Review Guidelines

Review-specific guidance. `CLAUDE.md` carries this repository's standing rules and is
ingested alongside this file — nothing here restates it. These are the diff-level cues
and the noise filters.

## Critical Areas

- **The controller boundary.** Flag `Components.Schemas.*` / `Operations.*` types
  in views or view models — generated types stop at the controller. `import
  Salon1cAPI` in a view file is the same flag.
- **Secrets.** Flag any literal API key or salon GUID other than the mock
  defaults in `Salon.xcconfig`. Flag a committed `Salon.local.xcconfig` or a diff
  that un-ignores it.
- **Generated files.** `project.pbxproj` and generated schemes are never
  committed — `project.yml` is the source of truth. Flag a committed pbxproj or
  a diff that removes it from `.gitignore`.
- **Structured files.** `*-Info.plist`, `*.xcstrings`, `PrivacyInfo.xcprivacy`,
  `Contents.json`, `.devin/wiki.json` are authored by `plutil`/`jq` — a
  hand-formatted one that no longer parses is a defect. Flag a URL written into
  an xcconfig *without* the `$()` `//`-comment split.
- **The two pins.** `Salon1c` is pinned at `minorVersion`/`upToNextMinor` in
  `project.yml` and `SalonKit/Package.swift` — flag a diff that moves one pin
  without the other.

## Conventions

- Require a running `#Preview` on every view in the diff; flag a preview that
  needs an `.environment(…)` object it does not construct itself.
- Flag `try!`, `fatalError`, force-unwrap of optional state, or a singleton in
  app code — unconfigured/offline/refused are rendered states.
- Flag a new `// TODO` in Swift code that carries no `SA-n` register number.
- Require Swift Testing (`@Test`/`#expect`) for new logic tests; XCTest appears
  only for `XCUIApplication`.
- Flag wire vocabulary in UI strings — visit/booking/master/service/balance/
  package/certificate, never record/ticket/deposit/usertoken/parameters.
- Flag a feature that needs API surface absent from `Salon1cAPI` built against
  hand-rolled URLs — the package grows first (rule 9).

## Ignore

- Skip formatting-only churn in `Positioning.md` — it is draft prose.
- The mock defaults in `Salon.xcconfig` are deliberate — a public mock that
  accepts any key; not a leaked credential.
- English-only UI strings are intentional for now — Russian lands via string
  catalogs (Roadmap).
- `Package.resolved` is tracked on purpose — an app pins its dependencies.
