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
    private var coordinator: SearchCoordinator
    var viewState: SearchViewState = .idle
    
    var searchText: String = ""
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .sortOrder] //price range halt
    
    var fetchedSearchResults: [AuctionCardModel] = []
    var isFetchingSearchResults: Bool = false
    var shouldFetchMoreSearchItem: Bool = true
    
    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }
    
    func isFilterSet(for type: FilterType ) -> Bool {
        var isSet: Bool = false
        switch type {
            case .auctionType:
                isSet = filterModel.activeAuctionTypeFilter != .all
            case .category:
                isSet = filterModel.activeCategoryFilter != .all
            case .priceRange:
                isSet = filterModel.activePriceRangeFilter != nil
            case .sortOrder:
                isSet = filterModel.activeSortOrderFilter != .relevance
        }
        return isSet
    }
    
    func makeSearchRequest(preserveFilters: Bool = false) {
        self.fetchedSearchResults.removeAll()
        if !preserveFilters {
            self.resetFilters()
        }
        self.getSearchResults()
    }
    
    private func resetFilters() {
        self.filterModel = .init(serchTerm: self.searchText.isEmpty ? nil : self.searchText)
    }
    
    func getSearchResults() {
        Task {
            guard shouldFetchMoreSearchItem, !isFetchingSearchResults else { return }
            self.isFetchingSearchResults = true
            self.filterModel.serchTerm = self.searchText.isEmpty ? nil : self.searchText
            defer {
                self.viewState = .fetched
                self.isLoading = false
                self.isFetchingSearchResults = false
            }
            try? await Task.sleep(for: .seconds(2))
            self.fetchedSearchResults.append(contentsOf: AuctionCardModel.mockData) //try await self.coordinator.appContainer.resolve(SearchServiceProtocol.self).getSearchResults(searchText: self.searchText, filterModel: self.filterModel)
            self.shouldFetchMoreSearchItem = self.fetchedSearchResults.count < 230
        }
    }
    
    func getAuctionDetail(_ auctionID: UUID) {
        Task {
            print(auctionID)
        }
    }
    
    @MainActor
    func openFilterSheet(for filter: FilterType) {
        switch filter {
            case .auctionType:
                self.coordinator.openSelectableFilterSheet(filter: self.filterModel.activeAuctionTypeFilter) { newValue in
                    self.filterModel.activeAuctionTypeFilter = newValue
                    self.coordinator.dismiss()
                    self.makeSearchRequest(preserveFilters: true)
                } onCancel: {
                    self.coordinator.dismiss()
                }

            case .sortOrder:
                self.coordinator.openSelectableFilterSheet(filter: self.filterModel.activeSortOrderFilter) { newValue in
                    self.filterModel.activeSortOrderFilter = newValue
                    self.coordinator.dismiss()
                    self.makeSearchRequest(preserveFilters: true)
                } onCancel: {
                    self.coordinator.dismiss()
                }
            case .category:
                self.coordinator.openSelectableFilterSheet(filter: self.filterModel.activeCategoryFilter) { newValue in
                    self.filterModel.activeCategoryFilter = newValue
                    self.coordinator.dismiss()
                    self.makeSearchRequest(preserveFilters: true)
                } onCancel: {
                    self.coordinator.dismiss()
                }
            case .priceRange:
                return
        }
        
    }
}
