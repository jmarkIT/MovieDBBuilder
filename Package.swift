// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MovieDBBuilder",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.0"
        ),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.8.0"),
        .package(
            url: "https://github.com/jmarkIT/SwiftTMDB.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/jmarkIT/SwiftNotion.git",
            branch: "main"
        ),
    ],
    targets: [
        // Targets are the basic building
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "MovieDBBuilder",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "SwiftTMDB", package: "SwiftTMDB"),
                .product(name: "SwiftNotion", package: "SwiftNotion")
            ],
            path: "Sources"
        )
    ]
)
