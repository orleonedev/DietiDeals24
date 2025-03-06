//
//  AuctionCardDTO.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation


struct AuctionCardDTO: Decodable {
    public var mainImageUrl: String?
    public var id: UUID?
    public var title: String?
    public var type: AuctionType?
    public var currentPrice: Double?
    public var endingDate: Date?
    public var bids: Int?
    
    private enum CodingKeys: String, CodingKey {
        case mainImageUrl
        case id
        case title
        case type
        case currentPrice
        case endingDate
        case bids
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mainImageUrl = try container.decodeIfPresent(String.self, forKey: .mainImageUrl)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        let dateString = try container.decodeIfPresent(String.self, forKey: .endingDate)
        if let dateString = dateString {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .endingDate,
                    in: container,
                    debugDescription: "Invalid date format: \(dateString)"
                )
            }
            self.endingDate = date
        } else {
            self.endingDate = nil
        }
        
        bids = try container.decodeIfPresent(Int.self, forKey: .bids)
        
        if let rawValue = try container.decodeIfPresent(Int.self, forKey: .type) {
            type = AuctionType(rawValue: rawValue)
        }
    }
    
    
}

extension AuctionCardModel {
    
    enum AuctionViewModelError: Error {
        case missingValue(String)
    }
    
    init(from dto: AuctionCardDTO) throws {
        guard let mainImageUrl = dto.mainImageUrl else {
            throw AuctionViewModelError.missingValue("mainImageUrl")
        }
        guard let id = dto.id else {
            throw AuctionViewModelError.missingValue("id")
        }
        guard let title = dto.title else {
            throw AuctionViewModelError.missingValue("title")
        }
        guard let type = dto.type else {
            throw AuctionViewModelError.missingValue("type")
        }
        guard let currentPrice = dto.currentPrice else {
            throw AuctionViewModelError.missingValue("currentPrice")
        }
        guard let endingDate = dto.endingDate else {
            throw AuctionViewModelError.missingValue("endingDate")
        }
        guard let bids = dto.bids else {
            throw AuctionViewModelError.missingValue("bids")
        }

        self.coverUrl = mainImageUrl
        self.id = id
        self.name = title
        self.auctionType = type
        self.price = currentPrice.formatted()
        self.endTime = endingDate
        self.bidsCount = bids
    }
}
