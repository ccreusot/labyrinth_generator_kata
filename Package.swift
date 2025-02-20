// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "labyrinth_generator",
    platforms: [.macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "labyrinth_generator",
            targets: ["labyrinth_generator"]),

        .library(
            name: "labyrinth_generator_lib",
            targets: ["labyrinth_generator_lib"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "labyrinth_generator",
            dependencies: [
                "labyrinth_generator_lib",
                "raylib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "labyrinth_generator_lib"),
        .target(
            name: "raylib",
            path: "raylib/build/raylib",
            linkerSettings: [
                .linkedLibrary("raylib"),
                .linkedLibrary("m"),
                .linkedFramework("Foundation", .when(platforms: [.macOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.macOS])),
                .linkedFramework("AppKit", .when(platforms: [.macOS])),
                // tell the linker to find the (`.a`) library in this path
                .unsafeFlags(["-Xlinker", "-Lraylib/build/raylib"]),
            ]),
        .testTarget(
            name: "labyrinth_generatorTests",
            dependencies: ["labyrinth_generator_lib"]
        ),
    ]
)
