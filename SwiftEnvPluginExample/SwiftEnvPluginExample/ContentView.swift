//
//  ContentView.swift
//  SwiftEnvPluginExample
//
//  Created by Mukesh Yadav on 29/12/24.
//

import SwiftUI

struct ContentView: View {
    let value: String
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, \(value)!")
        }
        .padding()
    }
}

#Preview {
    ContentView(value: "World")
}
