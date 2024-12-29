//
//  SwiftEnvGeneratorTests.swift
//  SwiftEnvPlugin
//
//  Created by Mukesh Yadav on 19/12/24.
//

import Foundation
import XCTest
@testable import SwiftEnvGenerator

class SwiftEnvGeneratorTests: XCTest {
    func testEnvPass() async {
        // Create test json
        let json = """
        {
            "key1": "ENV1",
            "key2": "ENV2",
            "key3": {
                "key4": "ENV3"
            }
        }
        """.data(using: .utf8)!
        try? await SwiftEnvGenerator
            .generate(inputData: json, outputPath: "/tmp/SwiftEnv.swift")
    }
}
