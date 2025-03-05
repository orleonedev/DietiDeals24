//
//  AuctionDetailDTO.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

struct AuctionImageDTO: Decodable {
    public let id: UUID?
    public let auctionId: UUID?
    public let url: String?
}

struct AuctionDetailDTO: Decodable {
    public var id: UUID?
    public var title: String?
    public var auctionImages: [String]?
    public var category: AuctionCategory?
    public var auctionType: AuctionType?
    public var currentPrice: Double?
    public var threshold: Double?
    public var startingDate: Date?
    public var endingDate: Date?
    public var timer: Int?
    public var bids: [AuctionBidDTO]?
    public var auctionDescription: String?
    public var secretPrice: Double?
    public var vendorId: UUID?
    public var vendor: VendorProfileResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case auctionImages
        case id
        case title
        case auctionType
        case currentPrice
        case startingDate
        case threshold
        case timer
        case bids
        case auctionDescription
        case category
        case endingDate 
        case secretPrice
        case vendorId
        case vendor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        let imagesDto = try container.decodeIfPresent([AuctionImageDTO].self, forKey: .auctionImages)
        auctionImages = imagesDto?.compactMap({$0.url})
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        threshold = try container.decodeIfPresent(Double.self, forKey: .threshold)
        let startingDateString = try container.decodeIfPresent(String.self, forKey: .startingDate)
        if let startingDateString = startingDateString {
            let formatter = DateFormatter()
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
        
        timer = try container.decodeIfPresent(Int.self, forKey: .timer)
        bids = try container.decodeIfPresent([AuctionBidDTO].self, forKey: .bids)
        auctionDescription = try container.decodeIfPresent(String.self, forKey: .auctionDescription)
        secretPrice = try container.decodeIfPresent(Double.self, forKey: .secretPrice)
        vendorId = try container.decodeIfPresent(UUID.self, forKey: .vendorId)
        vendor = try container.decodeIfPresent(VendorProfileResponseDTO.self, forKey: .vendor)
        
        if let categoryRawValue = try container.decodeIfPresent(Int.self, forKey: .category) {
            category = AuctionCategory(rawValue: categoryRawValue)
        }
        
        if let typeRawValue = try container.decodeIfPresent(Int.self, forKey: .auctionType) {
            auctionType = AuctionType(rawValue: typeRawValue)
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
        guard let description = dto.auctionDescription else {
            throw AuctionDetailModelError.missingValue("auctionDescription")
        }
        guard let category = dto.category else {
            throw AuctionDetailModelError.missingValue("category")
        }
        guard let auctionType = dto.auctionType else {
            throw AuctionDetailModelError.missingValue("auctionType")
        }
        guard let currentPrice = dto.currentPrice else {
            throw AuctionDetailModelError.missingValue("currentPrice")
        }
        guard let threshold = dto.threshold else {
            throw AuctionDetailModelError.missingValue("threshold")
        }
        guard let timer = dto.timer else {
            throw AuctionDetailModelError.missingValue("timer")
        }
        guard let endTime = dto.endingDate else {
            throw AuctionDetailModelError.missingValue("endingDate")
        }
        guard let vendorId = dto.vendorId else {
            throw AuctionDetailModelError.missingValue("vendorId")
        }
//        guard let vendor = dto.vendor else {
//            throw AuctionDetailModelError.missingValue("vendor")
//        }
        
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.images = dto.auctionImages ?? []
        self.auctionType = auctionType
        self.currentPrice = currentPrice
        self.threshold = threshold
        self.timer = timer
        self.secretPrice = dto.secretPrice
        self.endTime = endTime
        self.vendorID = vendorId
        self.vendorName = dto.vendor?.vendorName ?? ""
        
    }
}
