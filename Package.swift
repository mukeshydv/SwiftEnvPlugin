// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEnvPlugin",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .watchOS(.v4), .tvOS(.v12)
    ],
    products: [
        // Products can be used to vend plugins, making them visible to other packages.
        .plugin(name: "SwiftEnvPlugin", targets: ["SwiftEnvPlugin"]),
        .plugin(name: "SwiftEnv-Generate", targets: ["SwiftEnv-Generate"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .plugin(
            name: "SwiftEnvPlugin",
            capability: .buildTool(),
            dependencies: ["SwiftEnvGenerator"]
        ),
        .plugin(
            name: "SwiftEnv-Generate",
            capability: .command(
                intent: .custom(
                    verb: "swiftenv-generate",
                    description: "Generate SwiftEnv configuration from environment variables"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates source code")
                ]
            ),
            dependencies: ["SwiftEnvGenerator"]
        ),
        .executableTarget(name: "SwiftEnvGenerator")
    ]
)
