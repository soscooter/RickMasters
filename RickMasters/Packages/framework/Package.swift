// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "framework",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "framework",
            targets: ["framework"]),
    ],
    dependencies: [
        // Добавляем зависимости
        .package(url: "https://github.com/layoutBox/PinLayout", .upToNextMajor(from: "1.10.0")),
        .package(url: "https://github.com/realm/realm-swift", .upToNextMajor(from: "10.42.0"))
    ],
    targets: [
        .target(
            name: "framework",
            dependencies: [
                .product(name: "PinLayout", package: "PinLayout"),
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources",
            resources: [
                .copy("Resources/Fonts/Gilroy"),
                .process("Resources/images/Statistic.xcassets")
            ]
        )
    ]
)
