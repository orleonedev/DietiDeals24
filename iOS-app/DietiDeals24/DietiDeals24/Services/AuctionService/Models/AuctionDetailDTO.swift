//
//  AuctionDetailDTO.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

struct AuctionDetailDTO: Decodable {
    public var id: UUID?
    public var title: String?
    public var imagesUrls: [String]?
    public var category: AuctionCategory?
    public var type: AuctionType?
    public var currentPrice: Double?
    public var threshold: Double?
    public var startDate: Date?
    public var endingDate: Date?
    public var thresholdTimer: Int?
    public var bids: Int?
    public var description: String?
    
    enum CodingKeys: String, CodingKey {
        case imagesUrls = "ImagesUrls"
        case id = "Id"
        case title = "Title"
        case type = "Type"
        case currentPrice = "CurrentPrice"
        case startDate = "StartDate"
        case threshold = "Threshold"
        case thresholdTimer = "ThresholdTimer"
        case bids = "Bids"
        case description = "Description"
        case category = "Category"
        case endingDate = "EndingDate"
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        imagesUrls = try container.decodeIfPresent([String].self, forKey: .imagesUrls)
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        threshold = try container.decodeIfPresent(Double.self, forKey: .threshold)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        endingDate = try container.decodeIfPresent(Date.self, forKey: .endingDate)
        thresholdTimer = try container.decodeIfPresent(Int.self, forKey: .thresholdTimer)
        bids = try container.decodeIfPresent(Int.self, forKey: .bids)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        if let categoryRawValue = try container.decodeIfPresent(String.self, forKey: .category) {
            category = AuctionCategory(rawValue: categoryRawValue)
        }
        
        if let typeRawValue = try container.decodeIfPresent(Int.self, forKey: .type) {
            type = AuctionType(rawValue: typeRawValue)
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
        guard let images = dto.imagesUrls, !images.isEmpty else {
            throw AuctionDetailModelError.missingValue("imagesUrls")
        }
        guard let auctionType = dto.type else {
            throw AuctionDetailModelError.missingValue("type")
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
        
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.images = images
        self.auctionType = auctionType
        self.currentPrice = currentPrice
        self.threshold = threshold
        self.timer = timer
        self.secretPrice = nil //dto.secretPrice
        self.endTime = endTime
        self.vendorID = UUID()
        self.vendorName = "Vendor Name"
    }
}
