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

        // Library added to support SwiftUI Preview (which only works within an app).
        // See the iosViewBuilder app. syoung 10/04/2022
        .library(
            name: "LocalPreview",
            targets: [
                "SharedResources",
            ]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 "1.6.0"..<"3.0.0"),
        .package(name: "AssessmentModel",
                 url: "https://github.com/Sage-Bionetworks/AssessmentModelKMM.git",
                 from: "0.11.1"),
        .package(name: "MobilePassiveData",
                 url: "https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git",
                 from: "1.5.0"),
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
