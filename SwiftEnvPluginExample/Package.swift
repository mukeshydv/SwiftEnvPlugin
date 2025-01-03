// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEnvPluginExample",
    platforms: [
        .macOS(.v10_13), .iOS(.v12)
    ],
    products: [
        // Products can be used to vend plugins, making them visible to other packages.
        .library(name: "SwiftEnvPluginExample", targets: ["SwiftEnvPluginExample"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../../SwiftEnvPlugin")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftEnvPluginExample",
            path: "SwiftEnvPluginExample"
        )
    ]
)
