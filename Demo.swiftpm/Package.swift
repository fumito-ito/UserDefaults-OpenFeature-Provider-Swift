// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Demo",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Demo",
            targets: ["AppModule"],
            bundleIdentifier: "com.fumito-ito.Demo",
            teamIdentifier: "K489QY5CFD",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .map),
            accentColor: .presetColor(.cyan),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/open-feature/swift-sdk", "0.0.2"..<"1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "UserDefaultsOpenFeatureProvider", package: "userdefaults-openfeature-provider-swift"),
                .product(name: "OpenFeature", package: "swift-sdk")
            ],
            path: "."
        )
    ]
)