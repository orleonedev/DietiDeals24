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
    
    internal var appContainer: AppContainer
    private var router: ExploreRouter
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.router = appContainer.unsafeResolve(ExploreRouter.self)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) { [self] in
            ExploreMainView(viewModel: appContainer.unsafeResolve(ExploreMainViewModel.self))
        }
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
    
    
}
