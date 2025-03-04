//
//  AuctionListRequestBody.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

struct AuctionListRequestBody: Encodable, BodyParameters {
    let page: Int
    let size: Int
    let category: AuctionCategory?
    let type: AuctionType?
    let order: SortOrderFilter?
    let minPrice: Double? = nil
    let maxPrice: Double? = nil
    
    enum CodingKeys: String, CodingKey {
        case page = "pageNumber"
        case size = "pageSize"
        case category = "Category"
        case type = "Type"
        case order = "Order"
        case minPrice = "MinPrice"
        case maxPrice = "MaxPrice"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(page, forKey: .page)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(minPrice, forKey: .minPrice)
        try container.encodeIfPresent(maxPrice, forKey: .maxPrice)

        if let category = category {
            try container.encode(category.rawValue, forKey: .category)
        }

        if let type = type {
            try container.encode(type.rawValue, forKey: .type)
        }

        if let order = order {
            try container.encode(order.rawValue, forKey: .order)
        }
    }
    
}
