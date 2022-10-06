// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MotorControl",
    defaultLocalization: "en",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v11),
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MotorControl",
            targets: [
                "MotorControlV1",
            ]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SageResearch",
                 url: "https://github.com/Sage-Bionetworks/SageResearch.git",
                 from: "4.6.1"),
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 from: "1.4.9"),
        .package(name: "MobilePassiveData",
                 url: "https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git",
                 from: "1.3.2"),
    ],
    targets: [
        
        .target(
            name: "MotorControlV1",
            dependencies: [.product(name: "JsonModel", package: "JsonModel"),
                           .product(name: "Research", package: "SageResearch"),
                           .product(name: "ResearchUI", package: "SageResearch", condition: .when(platforms: [.iOS])),
                           .product(name: "MobilePassiveData", package: "MobilePassiveData"),
                           .product(name: "MotionSensor", package: "MobilePassiveData"),
                           .target(name: "MCTResources", condition: .when(platforms: [.iOS])),
            ],
            path: "MotorControl/iOS"),
        
        .target(name: "MCTResources",
                path: "MotorControl/MCTResources/",
                resources: [
                    .process("Resources")
                ]),

        .testTarget(
            name: "MotorControlV1Tests",
            dependencies: [
                "MotorControlV1",
                .product(name: "JsonModel", package: "JsonModel"),
                .product(name: "Research_UnitTest", package: "SageResearch", condition: .when(platforms: [.iOS])),
            ],
            path: "MotorControlTests/Tests"),
        
    ]
)
