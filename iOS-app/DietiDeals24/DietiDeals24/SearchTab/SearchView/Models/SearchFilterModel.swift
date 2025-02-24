//
//  SearchFilterModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//

struct SearchFilterModel {
    var serchTerm: String?
    var activeAuctionTypeFilter: AuctionType?
    var activeSortOrderFilter: SortOrderFilter = .relevance
    var activeCategoryFilter: AuctionCategory?
    var activePriceRangeFilter: PriceRangeFilter?
    
    var auctionTypes: [AuctionType] = AuctionType.allCases
    var sortOrderTypes: [SortOrderFilter] = SortOrderFilter.allCases
    var categoryTypes: [AuctionCategory] = AuctionCategory.allCases
}

enum AuctionType: Int, CaseIterable {
    case incremental
    case descending
    
    var label: String {
        switch self {
            case .incremental:
                return "Incremental"
            case .descending:
                return "Descending"
        }
    }
    
    static var title: String {
        "Auction Type"
    }
}

enum SortOrderFilter: Int, CaseIterable {
    case relevance
    case priceAscending
    case priceDescending
    case newer
    
    var label: String {
        switch self {
            case .priceAscending:
                return "Price Ascending"
            case .newer:
                return "Newest"
            case .relevance:
                return "Relevance"
            case .priceDescending:
                return "Price Descending"
        }
    }
    
    static var title: String {
        "Order by"
    }
}

enum AuctionCategory: String, CaseIterable {
    case services = "services" //TODO: MAPPARE con UUID
    case Electronics = "Electronics"
    case Furniture = "Furniture"
    case Clothing = "Clothing"
    
    var label: String {
        switch self {
            case .services:
                return "Services"
            case .Electronics:
                return "Electronics"
            case .Furniture:
                return "Furniture"
            case .Clothing:
                return "Clothing"
        }
    }
    
    static var title: String {
        "Category"
    }
}

struct PriceRangeFilter {
    var min: Double?
    var max: Double?
    
   static var title: String {
        "Price Range"
    }
}

enum FilterType {
    case auctionType
    case sortOrder
    case category
    case priceRange
    
    var title: String {
        switch self {
            case .auctionType:
                return AuctionType.title
            case .sortOrder:
                return SortOrderFilter.title
            case .category:
                return AuctionCategory.title
            case .priceRange:
                return PriceRangeFilter.title
        }
    }
}
