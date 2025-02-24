//
//  NotificationCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class NotificationCoordinator: Coordinator {
    typealias NotificationRouter = RoutingKit.Router
    
    internal var appContainer: AppContainer
    private var router: NotificationRouter
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(NotificationRouter.self)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            Text("Notification Tab")
        }
    }
    
    
}
