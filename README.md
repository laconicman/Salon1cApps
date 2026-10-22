# Salon1cApps

Two **unofficial** iOS apps on the [1С:SPA-Салон API](https://salon1c.docs.apiary.io/)
via the [`Salon1cAPI`](https://github.com/laconicman/Salon1c) package —
**SalonBook**, the salon's own app for its customers, and **SalonDesk**, the
salon's day on a phone for its staff. What they are for and why white-label
first: [Positioning.md](Positioning.md).

**Status: scaffold.** SalonBook lists the salon served by the vendor's Apiary
mock, over real HTTP — the hello-wire proving xcconfig → Info.plist →
`SalonConfiguration` → `payload()` end to end. SalonDesk is a placeholder.
Nothing here has touched the live API — see
[Tech Debt](SalonKit/Sources/SalonKit/SalonKit.docc/TechDebt.md).

## Building

```console
% brew install xcodegen
% xcodegen generate        # the .xcodeproj is generated, not committed
% open Salon1cApps.xcodeproj
```

The OpenAPI generator runs as a build plugin — trust it when Xcode asks, or pass
`-skipPackagePluginValidation -skipMacroValidation` on the command line. The
kit's tests need no Xcode project: `swift test --package-path SalonKit`.

## Configuring a real salon

The committed `Salon.xcconfig` points at the vendor's Apiary mock, so a clean
clone runs. For a real salon, create the gitignored `Salon.local.xcconfig` next
to it — it is never committed:

```
SALON_ID = <salon guid>
SALON_API_KEY = <apikey>
SALON_SERVER_URL = http:/$()/cloud.salon1c.ru/api
```

The `$()` splits `//`, which the xcconfig parser would otherwise read as a
comment start.

## Direction

The DocC catalog inside the kit —
`SalonKit/Sources/SalonKit/SalonKit.docc/` — is authoritative (two apps share
one direction, so it lives in the kit): Vision · Design · Roadmap · TechDebt.
Render with
`swift package --package-path SalonKit generate-documentation --target SalonKit`.

## License

Apache 2.0 — see [LICENSE](LICENSE). Unofficial and unaffiliated with 1С.
