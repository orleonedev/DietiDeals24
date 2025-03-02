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
    var isSearching: Bool = false 
    
    var exploreItems: [AuctionCardModel] = []
    var isFetchingExploreItems: Bool = false
    var shouldFetchMoreExploreItem: Bool = true
    
    var searchItems: [AuctionCardModel] = []
    var searchText: String = ""
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .sortOrder] //price range halt
    var isFetchingSearchResults: Bool = false
    var shouldFetchMoreSearchItem: Bool = true
    
    
    init(coordinator: ExploreCoordinator) {
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
        self.searchItems.removeAll()
        if !preserveFilters {
            self.resetFilters()
        }
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
            self.searchItems = AuctionCardModel.mockData //try await self.coordinator.appContainer.resolve(SearchServiceProtocol.self).getSearchResults(searchText: self.searchText, filterModel: self.filterModel)
            self.shouldFetchMoreSearchItem = false//self.searchItems.count < 230
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
            self.shouldFetchMoreExploreItem = self.exploreItems.count < 128
        }
    }
    
    func getAuctionDetail(_ auctionID: UUID) {
        Task {
            print(auctionID)
            self.isLoading = true
            try? await Task.sleep(for: .seconds(2))
            let auction = AuctionDetailModel(
                id: auctionID,
                title: "TEST",
                description: "long description long very long description very ver long description vd long description long very long description very ver long description vd long description long very long description very ver long description vd",
                category: .Electronics,
                images: [],
                currentPrice: 12345,
                threshold: 12,
                timer: 34,
                endTime: .now.advanced(by: 60*60*34),
                vendorID: UUID(),
                vendorName: "Venditore Test"
            )
            self.isLoading = false
            await self.coordinator.goToAuction(auction)
            
        }
    }
    
    private func resetFilters() {
        self.filterModel = .init(serchTerm: self.searchText.isEmpty ? nil : self.searchText)
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
