//
//  SwiftEnvPluginExampleApp.swift
//  SwiftEnvPluginExample
//
//  Created by Mukesh Yadav on 29/12/24.
//

import SwiftUI

@main
struct SwiftEnvPluginExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                value: EnvironmentVar.config + " " + EnvironmentVar.objectNewKey
            )
        }
    }
}
