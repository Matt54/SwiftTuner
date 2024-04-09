// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftTuner",
    platforms: [.visionOS(.v1)],
    products: [
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
        .target(
            name: "SwiftTuner",
            dependencies: ["AudioKit", "AudioKitEX", "SoundpipeAudioKit"]),
        .testTarget(
            name: "SwiftTunerTests",
            dependencies: ["SwiftTuner"]),
    ]
)
