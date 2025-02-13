//
//  DietiDeals24App.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 26/11/24.
//

import SwiftUI

@main
struct DietiDeals24App: App {
    
    @State var launchScreenIsEnded = false
    @State var authFlow: AuthenticationFlow = AuthenticationFlow()
    var body: some Scene {
        WindowGroup {
            ZStack{
                if !launchScreenIsEnded {
                    LaunchScreenView(isEnded: $launchScreenIsEnded)
                } else {
                    if authFlow.isAuthenticated {
                        ContentView()
                    } else {
                        authFlow.root
                    }
                }
            }
            .animation(.easeInOut, value: launchScreenIsEnded)
            .animation(.easeInOut, value: authFlow.isAuthenticated)
            
        }
    }
}
