//
//  NotificationCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class NotificationCoordinator: Coordinator, UserProfileCoordinatorProtocol, AuctionCoordinatorProtocol {
    
    
    typealias NotificationRouter = RoutingKit.Router
    
    internal var appContainer: AppContainer
    internal var router: NotificationRouter
    private let appState: AppState
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(NotificationRouter.self)
        self.appState = appContainer.unsafeResolve(AppState.self)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            NotificationMainView(viewModel: self.appContainer.unsafeResolve(NotificationMainViewModel.self))
        }
    }
    
    func getUserData() async -> UserDataModel? {
        return await appState.getUserDataModel()
    }
    
    func auctionDetailDestination(_ auction: AuctionDetailModel) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(AuctionDetailMainViewModel.self, tag: .init("Notification"))
            vm.setAuction(auction)
            return AuctionDetailMainView(viewModel: vm)
            
        }
    }
    
    func vendorProfileDestination(_ vendor: VendorAuctionDetail) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(UserProfileViewModel.self, tag: .init("Notification"))
            vm.setVendor(vendor)
            return UserProfileView(viewModel: vm)
            
        }
    }
    
    func presentOfferSheetDestination(for auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)?) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(PresentOfferViewModel.self, tag: .init("Notification"))
            vm.setAuctionDetials(auction, onBidResult: onBidResult)
            return PresentOfferView(viewModel: vm)
        }
    }
    
}
