//
//  SwiftEnvGenerator.swift
//
//
//  Created by Mukesh Yadav on 19/12/24.
//

import Foundation

@main
@available(iOS 13.0.0, *)
@available(macOS 13.0.0, *)
struct SwiftEnvGenerator {
    static func main() async throws {
        // Use swift-argument-parser or just CommandLine, here we just imply that 2 paths are passed in: input and output
        guard CommandLine.arguments.count == 3 else {
            throw SwiftEnvGeneratorError.invalidArguments
        }
        
        // arguments[0] is the path to this command line tool
        let input = URL(fileURLWithPath: CommandLine.arguments[1])
        print(input)
        print(CommandLine.arguments[2])
        let data = try Data(contentsOf: input)
        try await generate(
            inputData: data,
            outputPath: CommandLine.arguments[2]
        )
    }
    
    static func generate(inputData: Data, outputPath: String) async throws {
        let outputUrl = URL(fileURLWithPath: outputPath)
        
        // Parse json to dictionary
        let json = try JSONSerialization.jsonObject(with: inputData, options: []) as? [String: Any]
        
        // Iterate over the dictionary recursively and convert to simple dictionary with all nested path combined with dot
        var flatDictionary: [String: String] = [:]
        func flattenDictionary(_ dictionary: [String: Any], prefix: String = "", variablePrefix: String = "") {
            for (key, value) in dictionary {
                let keyPath = prefix.isEmpty ? key : "\(prefix).\(key)"
                let variablePath = variablePrefix.isEmpty ? key : "\(variablePrefix)\(key.first!.uppercased())\(key.dropFirst())"
                if let value = value as? [String: Any] {
                    flattenDictionary(value, prefix: keyPath, variablePrefix: variablePath)
                } else if let value = value as? String {
                    flatDictionary[variablePath] = value
                } else {
                    flatDictionary[variablePath] = String(describing: value)
                }
            }
        }
        
        flattenDictionary(json ?? [:])
        
        // Iterate over the flat dictionary and find the value from the environment variable
        var envDictionary: [String: String] = [:]
        for (key, value) in flatDictionary {
            print("Variable for", value, ProcessInfo.processInfo.environment[value] ?? "Not found")
            envDictionary[key] = ProcessInfo.processInfo.environment[value]
        }
        
        // Create a swift file with path as the key and value as the environment variable
        let output = flatDictionary.map {
            "\tpublic static let \($0.key) = \"\(envDictionary[$0.key] ?? "null")\""
        }.joined(separator: "\n")
        
        let outputFile = """
        public enum SwiftEnv {
        \(output)
        }
        """
        
        guard let outputData = outputFile.data(using: .utf8) else {
            throw SwiftEnvGeneratorError.invalidData
        }
        
        try outputData.write(to: outputUrl, options: .atomic)
    }
}

enum SwiftEnvGeneratorError: Error {
    case invalidArguments
    case invalidData
}
