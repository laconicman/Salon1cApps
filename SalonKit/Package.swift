// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SalonKit",
    // iOS 17 for the apps it serves; macOS 14 so `swift test` runs on the Mac —
    // the same floor as the Salon1cAPI package it wraps (its Design article).
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "SalonKit", targets: ["SalonKit"])],
    dependencies: [
        // The API client, consumed by URL at the tagged minor so a clean clone builds
        // the published product. Pinned in two places — here and project.yml — and the
        // pins move together (Design → "the API package by URL").
        .package(url: "https://github.com/laconicman/Salon1c", .upToNextMinor(from: "0.3.3")),
        // The test seam (StubTransport : ClientTransport) and the default transport —
        // same floors Salon1c's own Package.swift declares.
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.1"),
        // Not a dependency: OSLogLoggingMiddleware — Salon1cAPI composes it internally
        // (Client.init); the kit never names it.
        // Command plugin for `swift package generate-documentation` — deliberately not
        // in any target's `plugins:` (same shape as the Salon1c package).
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "SalonKit",
            dependencies: [
                .product(name: "Salon1cAPI", package: "Salon1c"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ]
        ),
        .testTarget(
            name: "SalonKitTests",
            dependencies: ["SalonKit", .product(name: "Salon1cAPI", package: "Salon1c")]
        )
    ]
)
