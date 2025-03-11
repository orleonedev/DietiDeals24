//
//  AuctionBidDTO.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

import Foundation

struct AuctionBidDTO: Codable, BodyParameters {
    
    public let auctionId: UUID?
    public let buyerId: UUID?
    public let price: Double?
    
    enum CodingKeys: String, CodingKey {
        case auctionId
        case buyerId
        case price
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.auctionId = try container.decodeIfPresent(UUID.self, forKey: .auctionId)
        self.buyerId = try container.decodeIfPresent(UUID.self, forKey: .buyerId)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
    }
    
    internal init(auctionId: UUID? = nil, buyerId: UUID? = nil, price: Double? = nil) {
        self.auctionId = auctionId
        self.buyerId = buyerId
        self.price = price
    }
    
}

