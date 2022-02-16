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
                 from: "1.3.4"),
        .package(name: "SageResearch",
                 url: "https://github.com/Sage-Bionetworks/SageResearch.git",
                 from: "4.3.3"),
        .package(name: "MobilePassiveData",
                 url: "https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git",
                 from: "1.2.2"),
        .package(name: "MCTResources", path: "MotorControl/MotorControl/MCTResources/")
    ],
    targets: [

        // Research is the main target included in this repo. The "Formatters" and
        // "ExceptionHandler" targets are developed in Obj-c so they require a
        // separate target.
        .target(
            name: "MotorControl",
            dependencies: ["JsonModel",
                           .product(name: "Research", package: "SageResearch"),
                           .product(name: "ResearchUI", package: "SageResearch", condition: .when(platforms: [.iOS])),
                           .product(name: "MCTResources", package: "MCTResources", condition: .when(platforms: [.iOS])),
                           .product(name: "MobilePassiveData", package: "MobilePassiveData"),
                           .product(name: "MotionSensor", package: "MobilePassiveData"),
            ],
            path: "MotorControl/MotorControl/iOS"),

        .testTarget(
            name: "MotorControlTests",
            dependencies: [
                "MotorControl",
                .product(name: "Research_UnitTest", package: "SageResearch", condition: .when(platforms: [.iOS])),
            ],
            path: "MotorControl/MotorControlTests/Tests"),
        
    ]
)
