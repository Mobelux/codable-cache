// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "codable-cache",
    platforms: [.iOS(.v13),
                .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CodableCache",
            targets: ["CodableCache"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "git@github.com:Mobelux/DiskCache.git", from: "1.0.0"),
         .package(url: "git@github.com:apple/swift-crypto.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CodableCache",
            dependencies: ["DiskCache",
                           .product(name: "Crypto", package: "swift-crypto")
            ]),
        .testTarget(
            name: "CodableCacheTests",
            dependencies: ["CodableCache"]),
    ]
)
