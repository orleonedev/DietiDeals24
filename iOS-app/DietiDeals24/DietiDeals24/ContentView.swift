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
                .foregroundStyle(.dietiYellow)
            Text("Hello, \(env)!")
            Text("This is the start of cognito setup")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
