// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MotorControl",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MotorControl",
            targets: ["MotorControl"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SageResearch",
                 url: "https://github.com/Sage-Bionetworks/SageResearch.git",
                 .branch("swiftPM")),
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "MotorControl",
            dependencies: [
                .product(name: "Research", package: "SageResearch"),
                .product(name: "ResearchUI", package: "SageResearch"),
                .product(name: "ResearchMotion", package: "SageResearch"),
                "JsonModel",
            ],
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "MotorControlTests",
            dependencies: ["MotorControl",
                           .product(name: "Research_UnitTest", package: "SageResearch"),
            ]),
        
    ]
)
