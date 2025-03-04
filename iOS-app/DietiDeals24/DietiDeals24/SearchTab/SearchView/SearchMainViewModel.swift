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
        case fetched
    }
    
    internal var isLoading: Bool = false
    private var coordinator: SearchCoordinator
    var viewState: SearchViewState = .idle {
        didSet {
            if viewState == .idle {
                self.reset()
            }
        }
    }
    
    var searchText: String = ""
    var isSearching: Bool = false
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .sortOrder] //price range halt
    
    var fetchedSearchResults: [AuctionCardModel] = []
    var isFetchingSearchResults: Bool = false
    var shouldFetchMoreSearchItem: Bool = true
    
    func reset(preserveFilters: Bool = false) {
        self.fetchedSearchResults.removeAll()
        self.isFetchingSearchResults = false
        self.shouldFetchMoreSearchItem = true
        if !preserveFilters {
            self.resetFilters()
        }
    }
    
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
    
    public func setFilter<Filter: FilterModelProtocol>(for type: FilterType, value: Filter) {
        switch type {
            case .auctionType:
                guard let auctionTypeValue = value as? AuctionType else { return }
                filterModel.activeAuctionTypeFilter = auctionTypeValue
            case .category:
                guard let categoryTypeValue = value as? AuctionCategory else { return }
                filterModel.activeCategoryFilter = categoryTypeValue
            case .priceRange:
                break
                //filterModel.activePriceRangeFilter != nil
            case .sortOrder:
                guard let sortTypeValue = value as? SortOrderFilter else { return }
                filterModel.activeSortOrderFilter = sortTypeValue
        }
    }
    
    @MainActor
    func makeSearchRequest(preserveFilters: Bool = false) {
        self.isLoading = true
        self.isSearching = true
        self.reset(preserveFilters: preserveFilters)
        self.getSearchResults()
    }
    
    private func resetFilters() {
        self.filterModel = .init(serchTerm: self.searchText.isEmpty ? nil : self.searchText)
    }
    
    @MainActor
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
            self.shouldFetchMoreSearchItem = false//self.fetchedSearchResults.count < 230
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
