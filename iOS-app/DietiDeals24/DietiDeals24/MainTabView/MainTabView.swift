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
    let userAreaCoordinator: UserAreaCoordinator
    
    init(viewModel: MainTabViewModel, userAreaCoordinator: UserAreaCoordinator) {
        self.viewModel = viewModel
        self.userAreaCoordinator = userAreaCoordinator
    }
    public var body: some View {
        
        TabView(selection: $viewModel.activeTab) {
            
            Tab("Explore", systemImage: "house", value: 0) {
                exploreTabView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: 1) {
                searchItemsTabView()
            }
            Tab("Sell", systemImage: "plus.circle", value: 2) {
                sellTabView()
                    .task {
                        self.viewModel.sellCheck()
                    }
            }
            
            Tab("Notifications", systemImage: "bell", value: 3) {
                notificationTabView()
            }
            Tab("Personal Area", systemImage: "person", value: 4) {
                userAreaCoordinator.rootView()
            }
            
        }
    }
    
}

extension MainTabView {
    
    @ViewBuilder
    func exploreTabView() -> some View {
        NavigationStack{
            Text("Explore Tab")
        }
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

}

class MainTabCoordinator {
    typealias TabRouter = RoutingKit.Router
    
    let router: TabRouter
    let appContainer: AppContainer
    let userAreaTabCoordinator: UserAreaCoordinator
    
    init(appContainer: AppContainer) {
        self.router = appContainer.unsafeResolve(TabRouter.self)
        self.appContainer = appContainer
        self.userAreaTabCoordinator = appContainer.unsafeResolve()
    }
    
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        MainTabView(viewModel: self.appContainer.unsafeResolve(), userAreaCoordinator: self.userAreaTabCoordinator)
        
    }
    
    //FIXME: Non posso usare RoutableRootView altrimenti si scassano gli altri figli router
//    @MainActor
//    func becomeAVendor(onDismiss: @escaping () -> Void) {
//        self.router.navigate(to: becomeAVendorDestination(), type: .sheet, onDismiss: onDismiss)
//    }
//    
//    //MARK: DESTINATIONS
//    
//    private func becomeAVendorDestination() -> RoutingKit.Destination {
//        .init {
//            Text("Become a Vendor")
//                .interactiveDismissDisabled()
//                .toolbar {
//                    ToolbarItem(placement: .cancellationAction) {
//                        Button("Cancel") {
//                            self.router.dismiss()
//                        }
//                    }
//                }
//        }
//    }
}
