// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "labyrinth_generator",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "labyrinth_generator",
            targets: ["labyrinth_generator"]),

        .library(
            name: "labyrinth_generator_lib",
            targets: ["labyrinth_generator_lib"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "labyrinth_generator_lib"),
        .target(
            name: "labyrinth_generator",
            dependencies: ["labyrinth_generator_lib"]),
        .testTarget(
            name: "labyrinth_generatorTests",
            dependencies: ["labyrinth_generator_lib"]
        ),
    ]
)
