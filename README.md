# SwiftEnvPlugin

SwiftEnvPlugin is a Swift Package Manager (SPM) build tool plugin designed to generate a constants file (`SwiftEnv.swift`) automatically based on environment variables. This tool helps developers manage environment-specific configurations efficiently within Swift projects. 🌟🌟🌟

---

## Features 🌟🌟🌟

- Automatically generates a Swift file containing constants for environment variables. ✨
- Simplifies managing environment-specific values in Swift projects. ✨
- Fully integrates with Swift Package Manager's plugin system. ✨
- Customizable file and enum names, as well as access modifiers, via an xcconfig file. ✨

---

## Installation 🌟🌟🌟

### Add the Plugin to Your Project

To use `SwiftEnvPlugin`, include it in your `Package.swift` file: 🌟🌟🌟

```swift
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/mukeshydv/SwiftEnvPlugin.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            plugins: [
                .plugin(name: "SwiftEnvPlugin", package: "SwiftEnvPlugin")
            ]
        )
    ]
)
```

### Add a `swiftenv.json` File

Create a `swiftenv.json` file in the root of your project. This file defines the environment variables you want to include in the generated Swift code. Each key in the JSON file represents the name of the Swift variable, and its value is the corresponding environment variable name. 🌟🌟🌟

#### Example `swiftenv.json`

```json
{
    "apiKey": "MY_API_KEY",
    "baseUrl": "MY_BASE_URL"
}
```

In this example:
- `apiKey` will be set to the value of the `MY_API_KEY` environment variable. ✨
- `baseUrl` will be set to the value of the `MY_BASE_URL` environment variable. ✨

### Customize Using an xcconfig File

You can optionally provide an `swiftenv.xcconfig` file to customize the generated file and enum names, as well as the access modifier. 🌟🌟🌟

#### Example `swiftenv.xcconfig` File

```plaintext
MAPPER_FILE_NAME = swiftenvinput.json
OUTPUT_ENUM_NAME = EnvironmentVar
ACCESS_MODIFIER = internal
```

- `MAPPER_FILE_NAME`: Specifies the input JSON file name. ✨
- `OUTPUT_ENUM_NAME`: Defines the name of the generated enum. ✨
- `ACCESS_MODIFIER`: Sets the access level (`public`, `internal`, etc.) of the generated constants. ✨

---

## Usage 🌟🌟🌟

### Build and Generate Constants

When you build your project using `swift build` or Xcode, the plugin will: 🌟🌟🌟

1. Read the `swiftenv.json` file (or the file specified in the `.xcconfig` file).
2. Fetch the values of the specified environment variables.
3. Generate a `SwiftEnv.swift` file in the build directory with the specified enum name and access modifier.
4. Include the generated file in your build process.

### Access Generated Constants

In your Swift code, import the generated file and use the constants: 🌟🌟🌟

```swift
import Foundation

let apiKey = SwiftEnv.apiKey
print("API Key: \(apiKey)")
```

### Example Generated File

```swift
// SwiftEnv.swift

enum SwiftEnv {
    static let apiKey = "your_api_key"
    static let baseUrl = "https://example.com"
}
```

---

## Development 🌟🌟🌟

### How It Works

1. The plugin reads the `swiftenv.json` file (or the specified `MAPPER_FILE_NAME` in the `swiftenv.xcconfig` file) to determine the mapping of Swift variable names to environment variable names. ✨
2. It fetches the environment variable values during the build process. ✨
3. It generates a `SwiftEnv.swift` file (or the file with a name and enum specified in the `swiftenv.xcconfig` file) in a predefined directory. ✨

### Contributing

Contributions are welcome! If you find a bug or have an idea for an improvement: 🌟🌟🌟

1. Fork the repository.
2. Create a new branch (`feature/your-feature` or `bugfix/your-bugfix`).
3. Commit your changes.
4. Submit a pull request.

### Local Testing

To test the plugin locally: 🌟🌟🌟

1. Clone this repository.
2. Use `swift build` to build the package.
3. Link it to a sample project and verify functionality.

---

## License 🌟🌟🌟

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details. 🌟🌟🌟

---

## Contact 🌟🌟🌟

For questions or suggestions, please open an issue on GitHub or contact [Mukesh Yadav](https://github.com/mukeshydv). 🌟🌟🌟
