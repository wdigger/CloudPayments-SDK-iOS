// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CloudPayments",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CloudPaymentsSDK",
            targets: ["CloudPaymentsSDK"]),
        .library(
            name: "CloudPaymentsAPI",
            targets: ["CloudPaymentsAPI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CloudPaymentsSDK",
            dependencies: [
                "CloudPaymentsAPI",
                "YandexPaySDK",
            ],
            path: "sdk",
            exclude: ["Pods", "Tests"],
            resources: [
                            .process("Resources")
                        ]),
        .target(
            name: "CloudpaymentsNetworking",
            path: "networking",
            exclude: ["Tests"]),
        .target(
            name: "CloudPaymentsAPI",
            dependencies: [
                "CloudpaymentsNetworking",
            ],
            path: "api"),
        .binaryTarget(
            name: "YandexPaySDK",
            url: "https://yandexpay-ios-sdk.s3.yandex.net/1.4.0/YandexPaySDK.xcframework.zip",
            checksum: "cf9fa8cdd5affd120550ee5330dd1dec47ffa4c6829fa4861cbc9f0d334f77c6"),
    ]
)
