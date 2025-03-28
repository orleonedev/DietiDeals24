//
//  UserAreaCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI
import RoutingKit

class UserAreaCoordinator: Coordinator, UserProfileCoordinatorProtocol, AuctionCoordinatorProtocol {
    
    
    
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
    
    @MainActor
    func editVendorProfile(vendorId: UUID, shortBio: String, website: String, location: String, onEditComplete:  (() -> Void)?) {
        self.router.navigate(to: editVendorProfileDestination(vendorId: vendorId, shortBio: shortBio, website: website, location: location), type: .sheet, onDismiss: onEditComplete)
    }
    
    @MainActor
    func dismiss() {
        self.router.dismiss()
    }
    
    func auctionDetailDestination(_ auction: AuctionDetailModel) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(AuctionDetailMainViewModel.self, tag: .init("UserArea"))
            vm.setAuction(auction)
            return AuctionDetailMainView(viewModel: vm)
            
        }
    }
    
    
    // No Recursion, The auction view of my auctions does not show the vendor stack to navigate
    func vendorProfileDestination(_ vendor: VendorAuctionDetail) -> RoutingKit.Destination {
        .init {
            EmptyView()
        }
    }
    
    // on auction ownership, the present offer button won't appear
    func presentOfferSheetDestination(for auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)?) -> RoutingKit.Destination {
        .init {
            EmptyView()
        }
    }
    
    func editVendorProfileDestination(vendorId: UUID, shortBio: String, website: String, location: String) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(UpdateVendorDetailViewModel.self)
            vm.setupDetails(vendorId: vendorId, shortBio: shortBio, url: website, geoLocation: location)
            return UpdateVendorDetailView(viewModel: vm)
        }
    }
    
    @MainActor
    func logout() async {
        await self.appState.logOut()
    }
        
}


