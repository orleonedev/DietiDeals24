//
//  SearchFilterModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//

import Foundation

struct SearchFilterModel {
    var serchTerm: String?
    var activeAuctionTypeFilter: AuctionType = .all
    var activeSortOrderFilter: SortOrderFilter = .relevance
    var activeCategoryFilter: AuctionCategory = .all
    var activePriceRangeFilter: PriceRangeFilter?
    var vendorIdFilter: UUID?
}

enum AuctionType: Int, FilterModelProtocol {
    
    var value: Any {return self.rawValue}
    
    var id: Self {self}
    
    var description: String {
        return self.label
    }
    case all
    case incremental
    case descending
    
    var label: String {
        switch self {
            case .incremental:
                return "Incremental"
            case .descending:
                return "Descending"
            case .all:
                return "All"
        }
    }
    
    static var title: String {
        "Auction Type"
    }
}

enum SortOrderFilter: Int, FilterModelProtocol {
    
    var value: Any {return self.rawValue}
    
    var id: Self {self}
    
    var description: String {
        return self.label
    }
    
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

enum AuctionCategory: Int, FilterModelProtocol {
    
    var value: Any {return self.rawValue}
    
    var id: Self {self}
    
    var description: String {
        return self.label
    }
    case all = 0
    case services = 1
    case Electronics = 2
    case Furniture = 3
    case Clothing = 4
    
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
            case .all:
                return "All"
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

protocol FilterModelProtocol: Identifiable, Equatable, CustomStringConvertible, CaseIterable {
    var label: String { get }
    static var title: String { get }
    var value: Any { get }
    static var allCases: [Self] { get }
}
