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
    typealias SellingAuctionVM = AuctionDetailMainViewModel
    
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
    func dismiss(shouldReloadUserData: Bool = false) {
        if shouldReloadUserData {
            Task {
                try await self.appState.trySilentSignIn()
                self.router.dismiss( option: .toRoot )
            }
        } else {
            self.router.dismiss( option: .toRoot )
        }
    }
    
    @MainActor
    func goToBaseAuction() {
        self.router.navigate(to: baseAuctionDestination(), type: .sheet)
    }
    
    @MainActor
    func goToDetailAuction(baseAuction: CreateBaseAuctionModel) {
        self.router.navigate(to: detailAuctionDestination(baseAuction: baseAuction), type: .push)
    }

    @MainActor
    func goToAuctionPreview(auction: CreateAuctionModel) {
        self.router.navigate(to: auctionPreviewDestination(auction: auction), type: .push)
    }
    
    @MainActor
    func goToPublishedAuction(auction: AuctionDetailModel) {
        self.router.dismiss(option: .toRoot)
        self.router.navigate(to: publishedAuctionDestination(auction: auction), type: .sheet)
    }
    
    //MARK: DESTINATIONS
    private func becomeAVendorDestination() -> RoutingKit.Destination {
        .init {
            BecomeAVendorView(viewModel: self.appContainer.unsafeResolve())
        }
    }
    
    private func baseAuctionDestination() -> RoutingKit.Destination {
        .init {
            BaseAuctionDetailView(viewModel: self.appContainer.unsafeResolve())
        }
    }
    
    private func detailAuctionDestination(baseAuction: CreateBaseAuctionModel) -> RoutingKit.Destination {
        .init {
            let vm : TypedAuctionDetailViewModel = self.appContainer.unsafeResolve()
            vm.setBaseAuction(baseAuction)
            return TypedAuctionDetailView(viewModel: vm)
        }
    }
    
    private func auctionPreviewDestination(auction: CreateAuctionModel) -> RoutingKit.Destination {
        .init {
            let vm : AuctionPreviewViewModel = self.appContainer.unsafeResolve()
            vm.setAuction(auction)
            return AuctionPreviewView(viewModel: vm)
        }
    }
    
    private func publishedAuctionDestination(auction: AuctionDetailModel) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(SellingAuctionVM.self, tag: .init("Selling"))
            vm.setAuction(auction)
            return AuctionDetailMainView(viewModel: vm)
        }
    }
}
