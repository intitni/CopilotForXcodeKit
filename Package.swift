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
            targets: ["CopilotForXcodeKit", "CopilotForXcodeModel"]
        ),
        .library(
            name: "CopilotForXcodeModel",
            targets: ["CopilotForXcodeModel"]
        ),
        .library(
            name: "XPCConcurrency",
            targets: ["XPCConcurrency"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/GottaGetSwifty/CodableWrappers.git", from: "2.0.7"),
    ],
    targets: [
        .target(
            name: "CopilotForXcodeKit",
            dependencies: [
                "XPCConcurrency",
                "CopilotForXcodeModel",
                .product(name: "CodableWrappers", package: "CodableWrappers"),
            ]
        ),
        .target(
            name: "CopilotForXcodeModel"
        ),
        .target(
            name: "XPCConcurrency"
        ),
        .testTarget(
            name: "CopilotForXcodeKitTests",
            dependencies: ["CopilotForXcodeKit"]
        ),
        .testTarget(
            name: "CopilotForXcodeModelTests",
            dependencies: ["CopilotForXcodeModel"]
        ),
    ]
)

