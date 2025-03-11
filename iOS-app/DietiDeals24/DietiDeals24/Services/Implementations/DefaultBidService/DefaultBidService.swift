//
//  DefaultBidService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

final class DefaultBidService: BidService {
    
    let rest: RESTDataSource
    
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func sendBid(bid: AuctionBidDTO) async throws -> AuctionBidDTO {
        let response: AuctionBidDTO = try await rest.getCodable(at: BidEndpoint.sendBid(bid).endpoint)
        return response
    }
    
    
}
