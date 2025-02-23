//
//  UserAreaCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI
import RoutingKit

class UserAreaCoordinator: Coordinator {
    typealias UserAreaRouter = RoutingKit.Router
    
    let appContainer: AppContainer
    let router: UserAreaRouter
    let appState: AppState
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(UserAreaRouter.self)
        self.appState = appContainer.unsafeResolve(AppState.self)
    }
    
    func getUserData() async -> UserDataModel? {
        return await appState.getUserDataModel()
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            UserAreaMainView(viewModel: self.appContainer.unsafeResolve(UserAreaMainViewModel.self))
            
        }
    }
}


