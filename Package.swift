// swift-tools-version: 5.7.1
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
    ],
    dependencies: [
        .package(
            url: "https://github.com/open-feature/swift-sdk.git",
            .upToNextMajor(from: "0.1.0")
        ),
    ],
    targets: [
        .target(
            name: "UserDefaultsOpenFeatureProvider",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-sdk"),
            ],
            path: "Sources/UserDefaultsOpenFeatureProvider",
            resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "UserDefaultsOpenFeatureProviderTests",
            dependencies: ["UserDefaultsOpenFeatureProvider"]),
    ]
)
