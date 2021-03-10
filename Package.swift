// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftLogging",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "SwiftLogging",
            targets: ["SwiftLogging"]),
    ],
    targets: [
        .target(
            name: "SwiftLogging",
            dependencies: []),
        .testTarget(
            name: "SwiftLoggingTests",
            dependencies: ["SwiftLogging"]),
    ]
)
