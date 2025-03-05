//
//  ExploreCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import RoutingKit
import SwiftUI

class ExploreCoordinator: Coordinator {
    typealias ExploreRouter = RoutingKit.Router
    typealias ExploreAuctionVM = AuctionDetailMainViewModel
    
    internal var appContainer: AppContainer
    private var router: ExploreRouter
    private let appState: AppState
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(ExploreRouter.self)
        self.appState = appContainer.unsafeResolve(AppState.self)
    }
    
    func getUserData() async -> UserDataModel? {
        return await appState.getUserDataModel()
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) { [self] in
            ExploreMainView(viewModel: appContainer.unsafeResolve(ExploreMainViewModel.self))
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
            let vm = self.appContainer.unsafeResolve(ExploreAuctionVM.self, tag: .init("Explore"))
            vm.setAuction(auction)
            return AuctionDetailMainView(viewModel: vm)
            
        }
    }
    
}
