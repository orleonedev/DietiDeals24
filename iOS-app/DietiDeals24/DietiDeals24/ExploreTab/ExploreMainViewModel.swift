//
//  ExploreMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/26/25.
//

import SwiftUI

@Observable
class ExploreMainViewModel: LoadableViewModel {
    
    enum ExploreState {
        case explore
        case loading
        case searching
    }
    
    internal var isLoading: Bool = false
    
    private var coordinator: ExploreCoordinator
    
    var state: ExploreState = .explore
    
    var exploreItems: [AuctionCardModel] = []
    var isFetchingExploreItems: Bool = false
    var shouldFetchMoreExploreItem: Bool = true
    
    var searchItems: [AuctionCardModel] = []
    var searchText: String = ""
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .priceRange, .sortOrder]
    var isFetchingSearchResults: Bool = false
    var shouldFetchMoreSearchItem: Bool = true
    
    
    init(coordinator: ExploreCoordinator) {
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
    
    func makeSearchRequest() {
        self.searchItems.removeAll()
        //self.resetFilters()
        self.getSearchResults()
    }
    
    func getSearchResults() {
        Task {
            guard shouldFetchMoreSearchItem, !isFetchingSearchResults else { return }
            isFetchingSearchResults = true
            defer {
                self.state = .searching
                self.isLoading = false
                self.isFetchingSearchResults = false
            }
            try? await Task.sleep(for: .seconds(2))
            self.searchItems.append(contentsOf: AuctionCardModel.mockData) //try await self.coordinator.appContainer.resolve(SearchServiceProtocol.self).getSearchResults(searchText: self.searchText, filterModel: self.filterModel)
            self.shouldFetchMoreSearchItem = self.searchItems.count < 230
        }
    }
    
    func getMoreExploreItems() {
        Task {
            guard shouldFetchMoreExploreItem, !isFetchingExploreItems else { return }
            isFetchingExploreItems = true
            defer {
                self.isFetchingExploreItems = false
            }
            try? await Task.sleep(for: .seconds(2))
            self.exploreItems.append(contentsOf: AuctionCardModel.mockData)   //try await self.coordinator.appContainer.resolve(SearchServiceProtocol.self).getSearchResults(searchText: self.searchText, filterModel: self.filterModel)
            self.shouldFetchMoreExploreItem = self.exploreItems.count < 120
        }
    }
    
    func getAuctionDetail(_ auctionID: UUID) {
        Task {
            print(auctionID)
        }
    }
    
}
