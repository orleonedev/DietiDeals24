//
//  MainTabView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI
import RoutingKit

public struct MainTabView: View, LoadableView {
    
    @State var viewModel: MainTabViewModel
    private let exploreCoordinator: ExploreCoordinator
    private let searchCoordinator: SearchCoordinator
    private let sellingCoordinator: SellingCoordinator
    private let notificationCoordinator: NotificationCoordinator
    private let userAreaCoordinator: UserAreaCoordinator
    
    init(viewModel: MainTabViewModel, userAreaCoordinator: UserAreaCoordinator, sellingCoordinator: SellingCoordinator, searchCoordinator: SearchCoordinator, exploreCoordinator: ExploreCoordinator, notificationCoordinator: NotificationCoordinator) {
        self.viewModel = viewModel
        self.userAreaCoordinator = userAreaCoordinator
        self.sellingCoordinator = sellingCoordinator
        self.notificationCoordinator = notificationCoordinator
        self.exploreCoordinator = exploreCoordinator
        self.searchCoordinator = searchCoordinator
    }
    
    public var body: some View {
        
        TabView(selection: $viewModel.activeTab) {
            
            Tab("Explore", systemImage: "house", value: 0) {
                exploreCoordinator.rootView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: 1) {
                searchCoordinator.rootView()
            }
                
            Tab("Sell", systemImage: "plus.circle", value: 2) {
                sellingCoordinator.rootView()
            }
            
            Tab("Notifications", systemImage: "bell", value: 3) {
                notificationCoordinator.rootView()
            }
            Tab("Personal Area", systemImage: "person", value: 4) {
                userAreaCoordinator.rootView()
            }
            
        }
    }
    
}
