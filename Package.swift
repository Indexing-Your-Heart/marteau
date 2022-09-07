// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Marteau",
    platforms: [.iOS(.v15), .macOS(.v12), .macCatalyst(.v15), .tvOS(.v15)],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/Indexing-Your-Heart/JensonKit", .branch("root")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "marteau",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "JensonKit", package: "JensonKit")
            ]),
        .testTarget(
            name: "marteauTests",
            dependencies: ["marteau"]),
    ]
)
