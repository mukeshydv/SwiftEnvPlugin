import PackagePlugin
import Foundation

@main
struct SwiftEnvPlugin: BuildToolPlugin {
    /// Entry point for creating build commands for targets in Swift packages.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        // This plugin only runs for package targets that can have source files.
        guard let sourceFiles = target.sourceModule?.sourceFiles else { return [] }
        
        // Find the code generator tool to run (replace this with the actual one).
        let generatorTool = try context.tool(named: "SwiftEnvGenerator")
        
        // Construct a build command for each source file with a particular suffix.
        return try generateCode(
            inputFiles: sourceFiles.map(\.url),
            outputDirectory: context.pluginWorkDirectoryURL,
            executablePath: generatorTool.url
        )
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftEnvPlugin: XcodeBuildToolPlugin {
    // Entry point for creating build commands for targets in Xcode projects.
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        // Find the code generator tool to run (replace this with the actual one).
        let generatorTool = try context.tool(named: "SwiftEnvGenerator")

        // Construct a build command for each source file with a particular suffix.
        return try generateCode(
            inputFiles: target.inputFiles.map(\.url),
            outputDirectory: context.pluginWorkDirectoryURL,
            executablePath: generatorTool.url
        )
    }
}

#endif
fileprivate func generateCode(inputFiles: [URL], outputDirectory: URL, executablePath: URL) throws -> [Command] {
    // Find the swiftenv.json file in the input files.
    var mapperFileName = "swiftenv.json"
    var outputEnumName = "SwiftEnv"
    var defaultAccessModifier = "public"
    
    if let configFile = inputFiles.first(
        where: { $0.lastPathComponent.lowercased() == "swiftenv.xcconfig"
        }) {
        // Parse the contents of the swiftenv.xcconfig file. without library
        let config = try parseXCConfigFile(atPath: configFile)
        if let mapper = config["MAPPER_FILE_NAME"] {
            mapperFileName = mapper
        }
        if let output = config["OUTPUT_ENUM_NAME"] {
            outputEnumName = output
        }
        if let accessModifier = config["ACCESS_MODIFIER"] {
            defaultAccessModifier = accessModifier
        }
    }
    
    guard let swiftenvFile = inputFiles.first(where: { $0.lastPathComponent.lowercased() == mapperFileName.lowercased() }) else {
        return []
    }
    let outputFilePath = outputDirectory.appending(path: outputEnumName + ".swift")
    
    // Construct a build command to run the code generator tool.
    return [.buildCommand(
        displayName: "Generating \(outputEnumName)",
        executable: executablePath,
        arguments: [
            swiftenvFile.absoluteString,
            outputFilePath.absoluteString,
            outputEnumName,
            defaultAccessModifier
        ],
        environment: [:],
        inputFiles: [swiftenvFile],
        outputFiles: [outputFilePath]
    )]
}

private func parseXCConfigFile(atPath url: URL) throws -> [String: String] {
    // Load the content of the file
    let content = try String(contentsOf: url, encoding: .utf8)
    
    // Create a dictionary to store key-value pairs
    var configDict: [String: String] = [:]
    
    // Split the content into lines
    let lines = content.components(separatedBy: .newlines)
    
    for line in lines {
        // Trim whitespace and ignore empty lines or comments
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") || trimmedLine.hasPrefix("#") {
            continue
        }
        
        // Split the line into key and value
        let components = trimmedLine.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        if components.count == 2 {
            let key = components[0]
            let value = components[1]
            configDict[key] = value
        }
    }
    
    return configDict
}
