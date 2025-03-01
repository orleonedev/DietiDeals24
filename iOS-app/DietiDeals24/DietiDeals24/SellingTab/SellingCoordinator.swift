//
//  SellingCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class SellingCoordinator: Coordinator {
    typealias SellingRouter = RoutingKit.Router
    
    internal var appContainer: AppContainer
    private var router: SellingRouter
    let appState: AppState
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(SellingRouter.self)
        self.appState = appContainer.unsafeResolve()
    }
    
    func getUserData() async -> UserDataModel? {
        return await appState.getUserDataModel()
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            SellingMainView(viewModel: self.appContainer.unsafeResolve())
        }
    }
    
    @MainActor
    func becomeAVendor(onDismiss: @escaping () -> Void) {
        self.router.navigate(to: becomeAVendorDestination(), type: .sheet, onDismiss: onDismiss)
    }
    
    @MainActor
    func dismiss() {
        self.router.dismiss()
    }

    //MARK: DESTINATIONS
    private func becomeAVendorDestination() -> RoutingKit.Destination {
        .init {
            BecomeAVendorView(viewModel: self.appContainer.unsafeResolve())
        }
    }
}
