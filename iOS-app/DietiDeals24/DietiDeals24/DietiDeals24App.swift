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
    @StateObject var authVM: MainAuthenticationViewModel = .init()
    var body: some Scene {
        WindowGroup {
            ZStack{
                if !launchScreenIsEnded {
                    LaunchScreenView(isEnded: $launchScreenIsEnded)
                } else {
                    if authVM.isAuthenticated{
                        ContentView()
                    } else {
                        MainAuthenticationView(viewModel: authVM)
                    }
                    
                }
            }
            .animation(.easeInOut, value: launchScreenIsEnded)
            .animation(.easeInOut, value: authVM.isAuthenticated)
            
        }
    }
}
