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
        return try generateCode(inputFiles: sourceFiles.map(\.path), outputDirectory: context.pluginWorkDirectory, executablePath: generatorTool.path)
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
        return try generateCode(inputFiles: target.inputFiles.map(\.path), outputDirectory: context.pluginWorkDirectory, executablePath: generatorTool.path)
    }
}

#endif
fileprivate func generateCode(inputFiles: [Path], outputDirectory: Path, executablePath: Path) throws -> [Command] {
    // Find the swiftenv.json file in the input files.
    guard let swiftenvFile = inputFiles.first(where: { $0.lastComponent == "swiftenv.json" }) else { return [] }
    let outputFilePath = outputDirectory.appending("SwiftEnv.swift")
    
    // Construct a build command to run the code generator tool.
    return [.buildCommand(
        displayName: "Generating SwiftEnv.swift",
        executable: executablePath,
        arguments: [swiftenvFile, outputFilePath],
        environment: [:],
        inputFiles: [swiftenvFile],
        outputFiles: [outputFilePath]
    )]
}
