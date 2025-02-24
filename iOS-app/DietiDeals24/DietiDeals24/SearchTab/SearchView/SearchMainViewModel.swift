//
//  SearchMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//

import SwiftUI

@Observable
class SearchMainViewModel: LoadableViewModel {
    
    enum SearchViewState {
        case idle
        case loading
        case fetched
    }
    
    internal var isLoading: Bool = false
    internal var coordinator: SearchCoordinator
    var viewState: SearchViewState = .idle
    
    var searchText: String = ""
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .priceRange, .sortOrder]
    
    var fetchedSearchResults: [AuctionCardModel] = []
    
    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }
    
    func isFilterSet(for type: FilterType ) -> Bool {
        var isSet: Bool = false
        switch type {
            case .auctionType:
                isSet = filterModel.activeAuctionTypeFilter != nil
            case .category:
                isSet = filterModel.activeCategoryFilter != nil
            case .priceRange:
                isSet = filterModel.activePriceRangeFilter != nil
            case .sortOrder:
                isSet = filterModel.activeSortOrderFilter != .relevance
        }
        return isSet
    }
    
    
    func getSearchResults() {
        Task {
            self.viewState = .loading
            self.isLoading = true
            defer {
                self.viewState = .fetched
                self.isLoading = false
            }
            try? await Task.sleep(for: .seconds(2))
            self.fetchedSearchResults = AuctionCardModel.mockData //try await self.coordinator.appContainer.resolve(SearchServiceProtocol.self).getSearchResults(searchText: self.searchText, filterModel: self.filterModel)
        }
    }
}
