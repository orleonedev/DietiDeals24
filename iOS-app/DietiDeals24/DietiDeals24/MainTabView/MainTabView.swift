//
//  MainTabView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI

public struct MainTabView: View, LoadableView {
    
    @State var viewModel: MainTabViewModel
    @State var appState: AppState
    public var body: some View {
        
        TabView(selection: $viewModel.activeTab) {
            
            Tab("Explore", systemImage: "house", value: 0) {
                exploreTabView(appState: self.appState)
            }
            Tab("Search", systemImage: "magnifyingglass", value: 1) {
                searchItemsTabView()
            }
            Tab("Sell", systemImage: "plus.circle", value: 2) {
                sellTabView()
            }
            Tab("Notifications", systemImage: "bell", value: 3) {
                notificationTabView()
            }
            Tab("Personal Area", systemImage: "person", value: 4) {
                UserAreaTabView()
            }
            
        }
    }
    
}

extension MainTabView {
    
    @ViewBuilder
    func exploreTabView(appState: AppState) -> some View {
        ContentView(appState: appState)
    }
    
    @ViewBuilder
    func searchItemsTabView() -> some View {
        NavigationStack{
            Text("Search Items Tab")
        }
    }
    
    @ViewBuilder
    func sellTabView() -> some View {
        NavigationStack{
            Text("Sell Tab")
        }
    }
    
    @ViewBuilder
    func notificationTabView() -> some View {
        NavigationStack{
            Text("notification Tab")
        }
    }
    
    @ViewBuilder
    func UserAreaTabView() -> some View {
        NavigationStack{
            Text("UserArea Tab")
        }
    }
}

#Preview {
    MainTabView(viewModel: .init(), appState: .init(credentialService: KeychainCredentialService(), authService: CognitoAuthService(rest: DefaultRESTDataSource())))
}
