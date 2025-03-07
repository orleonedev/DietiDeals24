//
//  BidEndpoint.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

import Foundation

enum BidEndpoint {
    case sendBid(AuctionBidDTO)
}

extension BidEndpoint {
    var endpoint : EndpointConvertible {
        switch self {
                case .sendBid(let bid):
                return Self.getSendBidEndpoint(bid: bid)
                
        }
    }
    
    static private func getSendBidEndpoint(bid: AuctionBidDTO) -> CodableEndpoint<AuctionBidDTO> {
                let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
                let httpMethod = HTTPMethod.post
                let encoding = Endpoint.Encoding.json
                let body = bid.jsonObject
        
        return CodableEndpoint<AuctionBidDTO>(
            Endpoint(
                baseURL: baseURLString,
                path: "/Bid/create-bid",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
        
}
