// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MBAutomation",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "MBAutomation",
            targets: ["MBAutomation"])

    ],
    dependencies: [
        .package(url: "https://github.com/Mumble-SRL/MBurgerSwift.git", from: "1.0.0"),
        .package(url: "https://github.com/Mumble-SRL/MBMessagesSwift.git", from: "0.1.1"),
        .package(url: "https://github.com/Mumble-SRL/MBAudienceSwift.git", from: "0.1.1"),
    ],
    targets: [
        .target(
            name: "MBAutomation",
            dependencies: ["MBurgerSwift", "MBMessagesSwift", "MBAudience"],
            path: "MBAutomation"
        ),
    ]
)
