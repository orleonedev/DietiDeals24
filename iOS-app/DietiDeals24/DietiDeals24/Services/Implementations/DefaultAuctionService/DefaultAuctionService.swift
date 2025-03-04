//
//  DefaultAuctionService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

final class DefaultAuctionService: AuctionService {
    
    let rest: RESTDataSource
    
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func fetchAuctions(filters: SearchFilterModel, page: Int, pageSize: Int) async throws -> PaginatedResult<AuctionCardDTO> {
        let response: PaginatedResult<AuctionCardDTO> = try await rest.getCodable(at: AuctionEndpoint.AuctionListEndpoint(filters: filters, page: page, pageSize: pageSize).endpoint)
        
        return response
    }
    
    func fetchAuctionDetails(by id: UUID) async throws -> AuctionDetailDTO {
        let response: AuctionDetailDTO = try await rest.getCodable(at: AuctionEndpoint.AuctionDetailEndpoint(id: id).endpoint)
        
        return response
    }
    
    
}
