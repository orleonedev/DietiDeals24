//
//  MainTabCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class MainTabCoordinator {
    typealias TabRouter = RoutingKit.Router
    
    private let router: TabRouter
    private let appContainer: AppContainer
    private let appState: AppState
    
    private let exploreCoordinator: ExploreCoordinator
    private let searchCoordinator: SearchCoordinator
    private let sellingCoordinator: SellingCoordinator
    private let notificationCoordinator: NotificationCoordinator
    private let userAreaCoordinator: UserAreaCoordinator
    
    init(appContainer: AppContainer) {
        self.router = appContainer.unsafeResolve(TabRouter.self)
        self.appContainer = appContainer
        self.userAreaCoordinator = appContainer.unsafeResolve()
        self.sellingCoordinator = appContainer.unsafeResolve()
        self.notificationCoordinator = appContainer.unsafeResolve()
        self.exploreCoordinator = appContainer.unsafeResolve()
        self.searchCoordinator = appContainer.unsafeResolve()
        self.appState = appContainer.unsafeResolve()
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        MainTabView(
            viewModel: self.appContainer.unsafeResolve(),
            userAreaCoordinator: self.userAreaCoordinator,
            sellingCoordinator: self.sellingCoordinator,
            searchCoordinator: self.searchCoordinator,
            exploreCoordinator: self.exploreCoordinator,
            notificationCoordinator: self.notificationCoordinator
        )
    }
    
}
