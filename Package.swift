// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "userdefaults-openfeature-provider-swift",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "userdefaults-openfeature-provider-swift",
            targets: ["userdefaults-openfeature-provider-swift"]),
    ],
    dependencies: [
        .package(
            name: "openfeature-swift-sdk",
            url: "git@github.com:open-feature/swift-sdk.git",
            .upToNextMajor(from: "0.0.2")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "userdefaults-openfeature-provider-swift",
            dependencies: [
                .product(name: "OpenFeature", package: "openfeature-swift-sdk"),
            ]),
        .testTarget(
            name: "userdefaults-openfeature-provider-swiftTests",
            dependencies: ["userdefaults-openfeature-provider-swift"]),
    ]
)
