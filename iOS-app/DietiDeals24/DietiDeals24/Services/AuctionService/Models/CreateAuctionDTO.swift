//
//  CreateAuctionDTO.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

struct CreateAuctionDTO: Encodable, BodyParameters {
    public var title: String?
    public var description: String?
    public var type: AuctionType?
    public var category: AuctionCategory?
    public var startingPrice: Double?
    public var threshold: Double?
    public var thresholdTimer: Int?
    public var imagesIdentifiers: [UUID]?
    public var secretPrice: Double?
    public var vendorId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case type
        case category
        case startingPrice
        case threshold
        case thresholdTimer
        case imagesIdentifiers
        case secretPrice
        case vendorId
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(type?.rawValue, forKey: .type)
        try container.encodeIfPresent(category?.rawValue, forKey: .category)
        try container.encodeIfPresent(startingPrice, forKey: .startingPrice)
        try container.encodeIfPresent(threshold, forKey: .threshold)
        try container.encodeIfPresent(thresholdTimer, forKey: .thresholdTimer)
        try container.encodeIfPresent(imagesIdentifiers, forKey: .imagesIdentifiers)
        try container.encodeIfPresent(secretPrice, forKey: .secretPrice)
        try container.encodeIfPresent(vendorId, forKey: .vendorId)

    }
    
    
    init(from model: CreateAuctionModel, vendorId: UUID) {
        title = model.baseDetail.title
        description = model.baseDetail.description
        type = model.auctionType
        category = model.baseDetail.category
        startingPrice = model.startingPrice
        threshold = model.threshold
        thresholdTimer = model.timer
        imagesIdentifiers = model.baseDetail.imagesPreview.compactMap({ preview in
            switch preview {
                case .success(let auctionImage):
                    return auctionImage.identifier
                default:
                    return nil
            }
        })
        secretPrice = model.secretPrice
        self.vendorId = vendorId
    }
}


struct CreateAuctionResponseDTO: Decodable {
    public let detailedAuction: AuctionDetailDTO?
    public let imagesPreSignedUrls: [UUID: String]?
    
    
    enum CodingKeys: CodingKey {
        case detailedAuction
        case imagesPreSignedUrls
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.detailedAuction = try container.decodeIfPresent(AuctionDetailDTO.self, forKey: .detailedAuction)
        let stringDict = try container.decode([String: String].self, forKey: .imagesPreSignedUrls)
        
        // Convert string keys to UUID
        imagesPreSignedUrls = Dictionary(uniqueKeysWithValues: stringDict.compactMap { key, value in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }
}
