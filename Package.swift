// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DomainParser",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DomainParser",
            targets: ["DomainParser"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DomainParser",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "DomainParserTests",
            dependencies: [
                "DomainParser",
            ]
            )
    ]
)
