//
//  BidService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

protocol BidService {
    
    func sendBid(bid: AuctionBidDTO) async throws -> AuctionBidDTO
    
}
