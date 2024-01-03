// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserDefaultsOpenFeatureProvider",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "UserDefaultsOpenFeatureProvider",
            targets: ["UserDefaultsOpenFeatureProvider"]),
        .library(
            name: "UserDefaultsOpenFeatureProviderSetterExpansion",
            targets: ["UserDefaultsOpenFeatureProviderSetterExpansion"]),
    ],
    dependencies: [
        .package(
            name: "openfeature-swift-sdk",
            url: "git@github.com:open-feature/swift-sdk.git",
            .upToNextMajor(from: "0.0.2")
        ),
    ],
    targets: [
        .target(
            name: "UserDefaultsOpenFeatureProvider",
            dependencies: [
                .product(name: "OpenFeature", package: "openfeature-swift-sdk"),
            ],
            path: "Sources/UserDefaultsOpenFeatureProvider"),
        .target(
            name: "UserDefaultsOpenFeatureProviderSetterExpansion",
            dependencies: ["UserDefaultsOpenFeatureProvider"],
            path: "Sources/UserDefaultsOpenFeatureProviderSetterExpansion"),
        .testTarget(
            name: "UserDefaultsOpenFeatureProviderTests",
            dependencies: ["UserDefaultsOpenFeatureProvider"]),
    ]
)
