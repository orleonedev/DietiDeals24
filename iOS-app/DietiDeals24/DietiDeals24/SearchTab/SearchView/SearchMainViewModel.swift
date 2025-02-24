//
//  SearchMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//

import SwiftUI

@Observable
class SearchMainViewModel: LoadableViewModel {
    internal var isLoading: Bool = false
    internal var coordinator: SearchCoordinator
    var searchText: String = ""
    var filterModel: SearchFilterModel = .init()
    let filteringOptions: [FilterType] = [.auctionType, .category, .priceRange, .sortOrder]
    
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
    
}
