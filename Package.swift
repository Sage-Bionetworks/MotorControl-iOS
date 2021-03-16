// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MotorControl",
    defaultLocalization: "en",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_15),
        .iOS(.v11),
        .watchOS(.v4),
        .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MotorControl",
            targets: ["MotorControl"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 "1.2.0"..<"1.3.0"),
        .package(name: "SageResearch",
                 url: "https://github.com/Sage-Bionetworks/SageResearch.git",
                 "4.0.0"..<"4.1.0"),
        
    ],
    targets: [

        // Research is the main target included in this repo. The "Formatters" and
        // "ExceptionHandler" targets are developed in Obj-c so they require a
        // separate target.
        .target(
            name: "MotorControl",
            dependencies: ["JsonModel",
                           .product(name: "Research", package: "SageResearch"),
                           .product(name: "ResearchUI", package: "SageResearch"),
                           .product(name: "ResearchMotion", package: "SageResearch"),
            ],
            path: "MotorControl/MotorControl/iOS",
            resources: [
                .process("Resources"),
            ]
            ),

        .testTarget(
            name: "MotorControlTests",
            dependencies: [
                "MotorControl",
                .product(name: "Research_UnitTest", package: "SageResearch"),
            ],
            path: "MotorControl/MotorControlTests/Tests",
            resources: [
                .process("Resources"),
            ]),
        
    ]
)
