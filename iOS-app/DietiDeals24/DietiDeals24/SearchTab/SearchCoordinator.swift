//
//  SearchCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class SearchCoordinator: Coordinator {
    typealias SearchRouter = RoutingKit.Router
    
    internal var appContainer: AppContainer
    private var router: SearchRouter
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(SearchRouter.self)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            SearchMainView(viewModel: self.appContainer.unsafeResolve(SearchMainViewModel.self))
        }
    }
    
    
}

