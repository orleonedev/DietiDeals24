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
        case searching
    }
    
    internal var isLoading: Bool = false
    
    private var coordinator: ExploreCoordinator
    
    var state: ExploreState = .explore {
        didSet {
            if state == .explore {
                self.resetSearchState()
            }
        }
    }
    
    var isSearching: Bool = false
    
    var exploreItems: [AuctionCardModel] = []
    let maxExploreItems: Int = 100
    var explorePage: Int = 1
    var explorePageSize: Int = 20
    var isFetchingExploreItems: Bool = false
    var shouldFetchMoreExploreItem: Bool = true
    
    var searchItems: [AuctionCardModel] = []
    var searchItemsCount: Int = 0
    var searchPage: Int = 1
    var searchPageSize: Int = 20
    var searchText: String = ""
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .sortOrder] //price range halt
    var isFetchingSearchResults: Bool = false
    var shouldFetchMoreSearchItem: Bool = true
    
    let auctionService: AuctionService
    
    init(coordinator: ExploreCoordinator, auctionService: AuctionService) {
        self.coordinator = coordinator
        self.auctionService = auctionService
    }
    
    func resetSearchState(preserveFilters: Bool = false) {
        self.searchItems.removeAll()
        self.searchItemsCount = 0
        self.searchPage = 1
        self.isFetchingSearchResults = false
        self.shouldFetchMoreSearchItem = true
        if !preserveFilters {
            self.resetFilters()
        }
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
    
    @MainActor
    func makeSearchRequest(preserveFilters: Bool = false) {
        self.isLoading = true
        self.isSearching = true
        self.resetSearchState(preserveFilters: preserveFilters)
        self.getSearchResults()
    }
    
    @MainActor
    func getSearchResults() {
        Task {
            guard shouldFetchMoreSearchItem, !isFetchingSearchResults else { return }
            isFetchingSearchResults = true
            defer {
                self.state = .searching
                self.isLoading = false
                self.isFetchingSearchResults = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            let searchItemsDto = try await auctionService.fetchAuctions(filters: filterModel, page: self.searchPage, pageSize: self.searchPageSize)
            let newSearchItems: [AuctionCardModel] = searchItemsDto.results.compactMap {try? AuctionCardModel(from: $0)}
            self.searchItemsCount = searchItemsDto.totalRecords
            self.searchPage = searchItemsDto.pageNumber
            self.searchItems.append(contentsOf: newSearchItems)
            self.shouldFetchMoreSearchItem = searchItemsCount > searchItems.count
        }
    }
    
    @MainActor
    func getMoreExploreItems() {
        Task {
            guard shouldFetchMoreExploreItem, !isFetchingExploreItems else { return }
            isFetchingExploreItems = true
            defer {
                self.isFetchingExploreItems = false
                self.isLoading = false
            }
            let exploreItemsDto = try await auctionService.fetchAuctions(filters: filterModel, page: self.explorePage, pageSize: self.explorePageSize)
            let newExploreItems: [AuctionCardModel] = exploreItemsDto.results.compactMap {try? AuctionCardModel(from: $0)}
            self.explorePage = exploreItemsDto.pageNumber
            self.exploreItems.append(contentsOf: newExploreItems)
            self.shouldFetchMoreExploreItem = maxExploreItems < exploreItemsDto.totalRecords ? maxExploreItems > exploreItems.count : exploreItems.count < exploreItemsDto.totalRecords
        }
    }
    
    func getAuctionDetail(_ auctionID: UUID) {
        Task {
            print(auctionID)
            self.isLoading = true
            
            let auctionDTO = try await auctionService.fetchAuctionDetails(by: auctionID)
            let model = try AuctionDetailModel(from: auctionDTO)
            
            self.isLoading = false
            await self.coordinator.goToAuction(model)
            
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
