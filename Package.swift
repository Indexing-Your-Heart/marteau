// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Marteau",
    platforms: [.iOS(.v15), .macOS(.v12), .macCatalyst(.v15), .tvOS(.v15)],
    products: [
        .library(name: "Marteau", targets: ["Marteau"]),
        .executable(name: "marteau-cli", targets: ["marteau-cli"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(
            url: "https://github.com/Indexing-Your-Heart/JensonKit",
            from: .init(0, 1, 0, prereleaseIdentifiers: ["alpha"])
        ),
        .package(url: "https://github.com/withfig/fig-swift-argument-parser", .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Marteau",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "JensonKit", package: "JensonKit"),
            ]
        ),
        .executableTarget(
            name: "marteau-cli",
            dependencies: [
                .target(name: "Marteau"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FigSwiftArgumentParser", package: "fig-swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "MarteauTests",
            dependencies: [
                .target(name: "Marteau"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "JensonKit", package: "JensonKit"),
            ]
        ),
    ]
)
