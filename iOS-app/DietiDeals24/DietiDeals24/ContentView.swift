//
//  ContentView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 26/11/24.
//

import SwiftUI

struct ContentView: View {
    
    var env: String {
#if DEV
        return "dev"
        #else
        return "prod"
#endif
    }
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, \(env)!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
