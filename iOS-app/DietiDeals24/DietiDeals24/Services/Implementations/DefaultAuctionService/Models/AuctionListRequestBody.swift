//
//  AuctionListRequestBody.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

struct AuctionListRequestBody: Encodable, BodyParameters {
    let page: Int
    let size: Int
    let searchText: String?
    let category: AuctionCategory?
    let type: AuctionType?
    let order: SortOrderFilter?
    let minPrice: Double?
    let maxPrice: Double?
    let vendorId: UUID? 
    
    enum CodingKeys: String, CodingKey {
        case page = "pageNumber"
        case size = "pageSize"
        case category = "category"
        case type = "type"
        case order = "order"
        case minPrice = "minPrice"
        case maxPrice = "maxPrice"
        case vendorId = "vendorId"
        case searchText = "searchText"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(page, forKey: .page)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(minPrice, forKey: .minPrice)
        try container.encodeIfPresent(maxPrice, forKey: .maxPrice)
        try container.encodeIfPresent(searchText, forKey: .searchText)
        
        if let category = category {
            try container.encode(category.rawValue, forKey: .category)
        }

        if let type = type {
            try container.encode(type.rawValue, forKey: .type)
        }

        if let order = order {
            try container.encode(order.rawValue, forKey: .order)
        }
        
        if let vendorId = vendorId {
            try container.encode(vendorId.uuidString, forKey: .vendorId)
        }
    }
    
}
