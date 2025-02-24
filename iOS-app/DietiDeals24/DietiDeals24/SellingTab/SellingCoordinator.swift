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
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(SellingRouter.self)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            Text("Selling Tab")
        }
    }
    
    @MainActor
    func becomeAVendor(onDismiss: @escaping () -> Void) {
        self.router.navigate(to: becomeAVendorDestination(), type: .sheet, onDismiss: onDismiss)
    }

    //MARK: DESTINATIONS
    private func becomeAVendorDestination() -> RoutingKit.Destination {
        .init {
            Text("Become a Vendor")
                .interactiveDismissDisabled()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.router.dismiss()
                        }
                    }
                }
        }
    }
}
