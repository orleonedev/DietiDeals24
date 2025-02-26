//
//  ExploreCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class ExploreCoordinator: Coordinator {
    typealias ExploreRouter = RoutingKit.Router
    
    internal var appContainer: AppContainer
    private var router: ExploreRouter
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(ExploreRouter.self)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) { [self] in
            ExploreMainView(viewModel: appContainer.unsafeResolve(ExploreMainViewModel.self))
        }
    }
    
    
}
