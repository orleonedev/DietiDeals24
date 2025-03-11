//
//  SearchCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class SearchCoordinator: Coordinator, AuctionCoordinatorProtocol, UserProfileCoordinatorProtocol {
    
    typealias SearchRouter = RoutingKit.Router
    typealias SearchAuctionVM = AuctionDetailMainViewModel
    
    internal var appContainer: AppContainer
    internal var router: SearchRouter
    let appState: AppState
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(SearchRouter.self)
        self.appState = appContainer.unsafeResolve(AppState.self)
    }
    
    func getUserData() async -> UserDataModel? {
        return await appState.getUserDataModel()
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            SearchMainView(viewModel: self.appContainer.unsafeResolve(SearchMainViewModel.self))
        }
    }
    
//    @MainActor
//    func goToAuction(_ auction: AuctionDetailModel) {
//        self.router.navigate(to: auctionDetailDestination(auction), type: .push)
//    }
    
    @MainActor
    func dismiss() {
        self.router.dismiss()
    }
    
    @MainActor
    func openSelectableFilterSheet<Filter: FilterModelProtocol>(filter: Filter, onSelect: @escaping (Filter) -> Void, onCancel: @escaping () -> Void) {
        self.router.navigate(to: selectableFilterSheet(filter: filter, onSelect: onSelect, onCancel: onCancel), type: .sheet)
    }

    //MARK: DESTINATIONS
    private func selectableFilterSheet<Filter: FilterModelProtocol>(filter: Filter, onSelect: @escaping (Filter) -> Void, onCancel: @escaping () -> Void) -> RoutingKit.Destination {
        .init {
            FilterSelectionSheet(title: Filter.title, options: Filter.allCases, selectedOption: filter, onSelect: onSelect, onCancel: onCancel)
        }
    }
    
    internal func auctionDetailDestination(_ auction: AuctionDetailModel) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(SearchAuctionVM.self, tag: .init("Search"))
            vm.setAuction(auction)
            return AuctionDetailMainView(viewModel: vm)
            
        }
    }
    
    func vendorProfileDestination(_ vendor: VendorAuctionDetail) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(UserProfileViewModel.self, tag: .init("Search"))
            vm.setVendor(vendor)
            return UserProfileView(viewModel: vm)
        }
    }
    
    internal func presentOfferSheetDestination(for auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)? = nil) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(PresentOfferViewModel.self, tag: .init("Search"))
            vm.setAuctionDetials(auction, onBidResult: onBidResult)
            return PresentOfferView(viewModel: vm)
        }
    }
    
}

