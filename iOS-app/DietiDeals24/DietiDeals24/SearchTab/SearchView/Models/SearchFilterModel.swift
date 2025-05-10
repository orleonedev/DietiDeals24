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
    case all = 0
    case incremental = 1
    case descending = 2
    
    var label: String {
        switch self {
            case .incremental:
                return "Incremental".localized
            case .descending:
                return "Descending".localized
            case .all:
                return "All".localized
        }
    }
    
    static var title: String {
        "Auction Type".localized
    }
}

enum SortOrderFilter: Int, FilterModelProtocol {
    
    var value: Any {return self.rawValue}
    
    var id: Self {self}
    
    var description: String {
        return self.label
    }
    
    case relevance = 0
    case newer = 1
    case priceAscending = 2
    case priceDescending = 3
    
    var label: String {
        switch self {
            case .priceAscending:
                return "Price Ascending".localized
            case .newer:
                return "Newest".localized
            case .relevance:
                return "Relevance".localized
            case .priceDescending:
                return "Price Descending".localized
        }
    }
    
    static var title: String {
        "Order by".localized
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
    case Collectibles = 5
    case Hobbies = 6
    case Other = 7
    
    var label: String {
        switch self {
            case .services:
                return "Services".localized
            case .Electronics:
                return "Electronics".localized
            case .Furniture:
                return "Furniture".localized
            case .Clothing:
                return "Clothing".localized
            case .all:
                return "All".localized
            case .Collectibles:
                return "Collectibles".localized
            case .Hobbies:
                return "Hobbies".localized
            case .Other:
                return "Other".localized
        }
    }
    
    static var title: String {
        "Category".localized
    }
}



struct PriceRangeFilter {
    var min: Double?
    var max: Double?
    
   static var title: String {
       "Price Range".localized
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
