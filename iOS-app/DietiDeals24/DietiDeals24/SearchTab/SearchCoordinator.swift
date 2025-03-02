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
    typealias SearchAuctionVM = AuctionDetailMainViewModel
    
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
    
    @MainActor
    func goToAuction(_ auction: AuctionDetailModel) {
        self.router.navigate(to: auctionDetailDestination(auction), type: .push)
    }
    
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
    
    private func auctionDetailDestination(_ auction: AuctionDetailModel) -> RoutingKit.Destination {
        .init {
            let vm = self.appContainer.unsafeResolve(SearchAuctionVM.self)
            vm.setAuction(auction)
            return AuctionDetailMainView(viewModel: vm)
            
        }
    }
    
}

