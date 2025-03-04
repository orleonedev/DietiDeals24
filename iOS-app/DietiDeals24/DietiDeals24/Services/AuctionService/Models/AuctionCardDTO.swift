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
    public var startDate: Date?
    public var threshold: Double?
    public var timer: Int?
    public var offers: Int?
    
    private enum CodingKeys: String, CodingKey {
        case mainImageUrl = "MainImageUrl"
        case id = "Id"
        case title = "Title"
        case type = "Type"
        case currentPrice = "CurrentPrice"
        case startDate = "StartDate"
        case threshold = "Threshold"
        case timer = "ThresholdTimer"
        case offers = "Bids"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mainImageUrl = try container.decodeIfPresent(String.self, forKey: .mainImageUrl)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        threshold = try container.decodeIfPresent(Double.self, forKey: .threshold)
        timer = try container.decodeIfPresent(Int.self, forKey: .timer)
        offers = try container.decodeIfPresent(Int.self, forKey: .offers)
        
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
        guard let startDate = dto.startDate else {
            throw AuctionViewModelError.missingValue("startDate")
        }
        guard let threshold = dto.threshold else {
            throw AuctionViewModelError.missingValue("threshold")
        }
        guard let timer = dto.timer else {
            throw AuctionViewModelError.missingValue("timer")
        }
        guard let offers = dto.offers else {
            throw AuctionViewModelError.missingValue("offers")
        }

        self.coverUrl = mainImageUrl
        self.id = id
        self.name = title
        self.auctionType = type
        self.price = String(currentPrice)
        self.endTime = startDate
        self.bidsCount = offers
    }
}
