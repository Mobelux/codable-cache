// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "codable-cache",
    platforms: [
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "CodableCache",
            targets: ["CodableCache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Mobelux/DiskCache.git", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "CodableCache",
            dependencies: [
                "DiskCache",
                .product(
                    name: "Crypto",
                    package: "swift-crypto")
            ]),
        .testTarget(
            name: "CodableCacheTests",
            dependencies: ["CodableCache"]),
    ]
)
