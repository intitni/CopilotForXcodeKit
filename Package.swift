// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CopilotForXcodeKit",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "CopilotForXcodeKit",
            targets: ["CopilotForXcodeKit"]
        ),
        .library(
            name: "XPCConcurrency",
            targets: ["XPCConcurrency"]
        ),
    ],
    targets: [
        .target(
            name: "CopilotForXcodeKit",
            dependencies: ["XPCConcurrency"]
        ),
        .target(
            name: "XPCConcurrency"
        ),
        .testTarget(
            name: "CopilotForXcodeKitTests",
            dependencies: ["CopilotForXcodeKit"]
        ),
    ]
)

