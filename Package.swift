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
                "MotorControl",
            ]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 from: "1.4.9"),
        .package(name: "AssessmentModel",
                 url: "https://github.com/Sage-Bionetworks/AssessmentModelKMM.git",
                 from: "0.8.6"),
        .package(name: "MobilePassiveData",
                 url: "https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git",
                 from: "1.3.2"),
    ],
    targets: [
        .target(
            name: "MotorControl",
            dependencies: [
                "SharedResources",
                .product(name: "JsonModel", package: "JsonModel"),
                .product(name: "AssessmentModel", package: "AssessmentModel"),
                .product(name: "AssessmentModelUI", package: "AssessmentModel"),
                .product(name: "MobilePassiveData", package: "MobilePassiveData"),
                .product(name: "MotionSensor", package: "MobilePassiveData"),
            ]
        ),
        .target(name: "SharedResources",
                dependencies: [
                    .product(name: "JsonModel", package: "JsonModel"),
                ],
                path: "shared_resources"),
        
        .testTarget(
            name: "MotorControlTests",
            dependencies: ["MotorControl"]),
    ]
)
