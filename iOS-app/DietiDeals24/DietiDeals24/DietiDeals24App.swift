//
//  DietiDeals24App.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 26/11/24.
//

import SwiftUI
import RoutingKit

@main
struct DietiDeals24App: App {
    
    @State var appContainer: AppContainer = AppContainer()
    var body: some Scene {
        WindowGroup {
            AppRootView(appContainer: appContainer)
        }
    }
}

