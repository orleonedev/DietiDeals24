//
//  AuctionDetailDTO.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

enum AuctionState: Int, Decodable {
    case open = 0,
        closed = 1,
        expired = 2
    
    var label: String {
        switch self {
            case .open:
                return "Active"
            case .closed:
                return "Closed"
            case .expired:
                return "Expired"
        }
    }
}

struct AuctionDetailDTO: Decodable {
    public var id: UUID?
    public var title: String?
    public var imagesUrls: [String]?
    public var category: AuctionCategory?
    public var type: AuctionType?
    public var currentPrice: Double?
    public var threshold: Double?
    public var startingDate: Date?
    public var endingDate: Date?
    public var thresholdTimer: Int?
    public var bids: Int?
    public var description: String?
    public var secretPrice: Double?
    public var state: AuctionState?
    public var vendor: VendorProfileResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case imagesUrls
        case id
        case title
        case type
        case currentPrice
        case startingDate
        case threshold
        case thresholdTimer
        case bids
        case description
        case category
        case endingDate 
        case secretPrice
        case vendor
        case state
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        imagesUrls = try container.decodeIfPresent([String].self, forKey: .imagesUrls)
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        threshold = try container.decodeIfPresent(Double.self, forKey: .threshold)
        let startingDateString = try container.decodeIfPresent(String.self, forKey: .startingDate)
        if let startingDateString = startingDateString {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = formatter.date(from: startingDateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .startingDate,
                    in: container,
                    debugDescription: "Invalid date format: \(startingDateString)"
                )
            }
            self.startingDate = date
        } else {
            self.startingDate = nil
        }
        
        let endingDateString = try container.decodeIfPresent(String.self, forKey: .endingDate)
        if let endingDateString = endingDateString {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = formatter.date(from: endingDateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .endingDate,
                    in: container,
                    debugDescription: "Invalid date format: \(endingDateString)"
                )
            }
            self.endingDate = date
        } else {
            self.endingDate = nil
        }
        
        thresholdTimer = try container.decodeIfPresent(Int.self, forKey: .thresholdTimer)
        bids = try container.decodeIfPresent(Int.self, forKey: .bids)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        secretPrice = try container.decodeIfPresent(Double.self, forKey: .secretPrice)
        vendor = try container.decodeIfPresent(VendorProfileResponseDTO.self, forKey: .vendor)
        
        if let categoryRawValue = try container.decodeIfPresent(Int.self, forKey: .category) {
            category = AuctionCategory(rawValue: categoryRawValue)
        }
        
        if let typeRawValue = try container.decodeIfPresent(Int.self, forKey: .type) {
            type = AuctionType(rawValue: typeRawValue)
        }
        if let stateRawValue = try container.decodeIfPresent(Int.self, forKey: .state) {
            state = AuctionState(rawValue: stateRawValue)
        }
    }
}


extension AuctionDetailModel {
    enum AuctionDetailModelError: Error {
        case missingValue(String)
    }
    
    init(from dto: AuctionDetailDTO) throws {
        guard let id = dto.id else {
            throw AuctionDetailModelError.missingValue("id")
        }
        guard let title = dto.title else {
            throw AuctionDetailModelError.missingValue("title")
        }
        guard let description = dto.description else {
            throw AuctionDetailModelError.missingValue("description")
        }
        guard let category = dto.category else {
            throw AuctionDetailModelError.missingValue("category")
        }
        guard let auctionType = dto.type else {
            throw AuctionDetailModelError.missingValue("auctionType")
        }
        guard let currentPrice = dto.currentPrice else {
            throw AuctionDetailModelError.missingValue("currentPrice")
        }
        guard let threshold = dto.threshold else {
            throw AuctionDetailModelError.missingValue("threshold")
        }
        guard let timer = dto.thresholdTimer else {
            throw AuctionDetailModelError.missingValue("thresholdTimer")
        }
        guard let endTime = dto.endingDate else {
            throw AuctionDetailModelError.missingValue("endingDate")
        }
        guard let startDate = dto.startingDate else {
            throw AuctionDetailModelError.missingValue("startingDate")
        }
        guard let state = dto.state else {
            throw AuctionDetailModelError.missingValue("state")
        }
        guard let vendor = dto.vendor else {
            throw AuctionDetailModelError.missingValue("vendor")
        }
        guard let bidsCount = dto.bids else {
            throw AuctionDetailModelError.missingValue("bids")
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.images = dto.imagesUrls ?? []
        self.auctionType = auctionType
        self.currentPrice = currentPrice
        self.threshold = threshold
        self.timer = timer
        self.secretPrice = dto.secretPrice
        self.endTime = endTime
        self.vendor = try VendorAuctionDetail(from: vendor)
        self.state = state
        self.startDate = startDate
        self.bidsCount = bidsCount
    }
}
