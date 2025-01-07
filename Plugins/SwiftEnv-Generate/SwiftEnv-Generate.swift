//
//  SwiftEnv-Generate.swift
//  SwiftEnv-Generate
//
//  Created by Mukesh Yadav on 31/12/24.
//

import Foundation
import PackagePlugin

@main
struct SwiftEnvPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let generatorTool = try context.tool(named: "SwiftEnvGenerator")
        let otherFiles = context.package.targets
            .compactMap { $0 as? SourceModuleTarget }
            .flatMap(\.sourceFiles)
            .map(\.path)
        otherFiles.forEach {  print($0) }
        try generateCode(
            directoryDirectory: context.package.directory,
            allFiles: otherFiles,
            executable: generatorTool
        )
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftEnvPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        let generatorTool = try context.tool(named: "SwiftEnvGenerator")
        let allFiles = context.xcodeProject.targets
            .map(\.inputFiles)
            .flatMap { $0.map(\.path) }
        try generateCode(
            directoryDirectory: context.xcodeProject.directory,
            allFiles: allFiles,
            executable: generatorTool
        )
    }
}

#endif

fileprivate func generateCode(
    directoryDirectory: Path,
    allFiles: [Path],
    executable: PackagePlugin.PluginContext.Tool
) throws {
    // Find the swiftenv.json file in the input files.
    var mapperFileName = "swiftenv.json"
    var outputEnumName = "SwiftEnv"
    var outputFilePath = ""
    var defaultAccessModifier = "public"
    
    let fileManager = FileManager.default
    
    let configuration = directoryDirectory.appending("swiftenv.xcconfig")
    var configFile: Path? = nil
    if fileManager.fileExists(atPath: configuration.string) {
        configFile = configuration
    } else {
        for file in allFiles where file.lastComponent.lowercased() == "swiftenv.xcconfig" {
            if fileManager.fileExists(atPath: file.string) {
                configFile = file
                break
            }
        }
    }
    
    if let configFile {
        // Parse the contents of the swiftenv.xcconfig file. without library
        let config = try parseXCConfigFile(atPath: configFile)
        if let mapper = config["MAPPER_FILE_NAME"] {
            mapperFileName = mapper
        }
        if let filePath = config["OUTPUT_FILE_PATH"] {
            outputFilePath = filePath
        }
        if let output = config["OUTPUT_ENUM_NAME"] {
            outputEnumName = output
        }
        if let accessModifier = config["ACCESS_MODIFIER"] {
            defaultAccessModifier = accessModifier
        }
    }
    
    // Get directory from the url
    let outputDirectory = configFile?.removingLastComponent() ?? directoryDirectory
    let swiftenvFile = outputDirectory.appending(mapperFileName)
    guard fileManager.fileExists(atPath: swiftenvFile.string) else {
        return
    }
    let outputFileURL = outputDirectory
        .appending(outputFilePath)
        .appending(outputEnumName + ".swift")
    
    // Construct a build command to run the code generator tool.
    let task = Process()
    task.executableURL = URL(filePath: executable.path.string)
    task.arguments = [
        swiftenvFile.string,
        outputFileURL.string,
        outputEnumName,
        defaultAccessModifier
    ]
    task.environment = ProcessInfo.processInfo.environment
    
    try task.run()
    task.waitUntilExit()
    
    // Check whether the subprocess invocation was successful.
    if task.terminationReason == .exit && task.terminationStatus == 0 {
        // do something?
        print("Generated \(outputFileURL)")
    } else {
        let problem = "\(task.terminationReason):\(task.terminationStatus)"
        Diagnostics.error("\(executable.name) invocation failed: \(problem)")
    }
}

private func parseXCConfigFile(atPath url: Path) throws -> [String: String] {
    // Load the content of the file
    let content = try String(contentsOfFile: url.string, encoding: .utf8)
    
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
