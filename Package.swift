// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTuner",
    platforms: [.visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftTuner",
            targets: ["SwiftTuner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.0.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX.git", from: "5.0.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", from: "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftTuner", dependencies: ["AudioKit", "AudioKitEX", "SoundpipeAudioKit"]),
        .testTarget(
            name: "SwiftTunerTests",
            dependencies: ["SwiftTuner"]),
    ]
)
