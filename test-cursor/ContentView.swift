//
//  ContentView.swift
//  test-cursor
//
//  Created by esikmalazman on 18/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var labelText = "Hello, world!"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(labelText)
            Button("Tap me") {
                labelText = "Look, I'm using AI!"
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
