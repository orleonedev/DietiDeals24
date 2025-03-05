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
    public let bidDate: Date?
    
}

