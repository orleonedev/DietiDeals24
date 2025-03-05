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
//    public let bidDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case auctionId
        case buyerId
        case price
//        case bidDate
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.auctionId = try container.decodeIfPresent(UUID.self, forKey: .auctionId)
        self.buyerId = try container.decodeIfPresent(UUID.self, forKey: .buyerId)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
//        let bidDateString = try container.decodeIfPresent(String.self, forKey: .bidDate)
//        if let bidDateString = bidDateString {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            guard let date = dateFormatter.date(from: bidDateString) else {
//                throw DecodingError.dataCorruptedError(
//                    forKey: .bidDate,
//                    in: container,
//                    debugDescription: "Invalid date format: \(bidDateString)"
//                )
//            }
//            self.bidDate = date
//        } else {
//            self.bidDate = nil
//        }
    }
}

