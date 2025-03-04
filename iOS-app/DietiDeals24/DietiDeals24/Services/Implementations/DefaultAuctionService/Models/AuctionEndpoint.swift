//
//  AuctionEndpoint.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

enum AuctionEndpoint {
    case auctionList(filters: SearchFilterModel, page: Int, pageSize: Int)
    case auctionDetail(id: UUID)
}

extension AuctionEndpoint {
    
    var endpoint: EndpointConvertible {
        switch self {
            case .auctionList(let filters, let page, let pageSize):
                return Self.AuctionListEndpoint(filters: filters, page: page, pageSize: pageSize)
            case .auctionDetail(let id):
                return Self.AuctionDetailEndpoint(id: id)
        }
    }
    
    static func AuctionListEndpoint(filters: SearchFilterModel, page: Int, pageSize: Int) -> CodableEndpoint<PaginatedResult<AuctionCardDTO>>  {
        
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let body = AuctionListRequestBody(
            page: page,
            size: pageSize,
            category: filters.activeCategoryFilter != .all ? filters.activeCategoryFilter : nil,
            type: filters.activeAuctionTypeFilter != .all ? filters.activeAuctionTypeFilter : nil,
            order: filters.activeSortOrderFilter != .relevance ? filters.activeSortOrderFilter : nil
        ).jsonObject
        
        return CodableEndpoint<PaginatedResult<AuctionCardDTO>>(
            Endpoint(
                baseURL: baseURLString,
                path: "Auction/get-paginated-auctions",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
    
    static func AuctionDetailEndpoint(id: UUID) -> CodableEndpoint<AuctionDetailDTO>  {
        
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.get
        
        return CodableEndpoint<AuctionDetailDTO>(
            Endpoint(
                baseURL: baseURLString,
                path: "Auction/get-auction-by-id/\(id)",
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
}
