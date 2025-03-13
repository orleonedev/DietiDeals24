//
//  AuctionDetailModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import Foundation

struct AuctionDetailModel: Equatable {
    static func == (lhs: AuctionDetailModel, rhs: AuctionDetailModel) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.title == rhs.title &&
                   lhs.description == rhs.description &&
                   lhs.category == rhs.category &&
                   lhs.images == rhs.images &&
                   lhs.auctionType == rhs.auctionType &&
                   lhs.currentPrice == rhs.currentPrice &&
                   lhs.threshold == rhs.threshold &&
                   lhs.timer == rhs.timer &&
                   lhs.secretPrice == rhs.secretPrice &&
                   lhs.endTime == rhs.endTime &&
                   lhs.vendor == rhs.vendor &&
                    lhs.state == rhs.state
        }
    
    var id: UUID
    var title: String
    var description: String
    var category: AuctionCategory
    var images: [String]
    var auctionType: AuctionType = .incremental
    var currentPrice: Double
    var threshold: Double
    var timer: Int
    var secretPrice: Double?
    var endTime: Date
    var vendor: VendorAuctionDetail
    var state: AuctionState
}

struct VendorAuctionDetail: Equatable {
    
    
    var id: UUID
    var name: String
    var username: String
    var email: String
    var successfulAuctions: Int
    var joinedSince: Date
    var geoLocation: String?
    var webSiteUrl: String?
    var shortBio: String?
    
    static func == (lhs: VendorAuctionDetail, rhs: VendorAuctionDetail) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.name == rhs.name &&
                   lhs.username == rhs.username &&
                   lhs.email == rhs.email &&
                   lhs.successfulAuctions == rhs.successfulAuctions &&
                   lhs.joinedSince == rhs.joinedSince &&
                   lhs.geoLocation == rhs.geoLocation &&
                   lhs.webSiteUrl == rhs.webSiteUrl &&
                   lhs.shortBio == rhs.shortBio
        }
    
    enum VendorAuctionDetailError: Error {
        case missingValue(String)
    }
    
    init(from dto: VendorProfileResponseDTO) throws {
        guard let id = dto.id else {throw VendorAuctionDetailError.missingValue("id")}
        guard let name = dto.name else {throw VendorAuctionDetailError.missingValue("name")}
        guard let username = dto.username else {throw VendorAuctionDetailError.missingValue("username")}
        guard let email = dto.email else {throw VendorAuctionDetailError.missingValue("email")}
        guard let successfulAuctions = dto.successfulAuctions else {throw VendorAuctionDetailError.missingValue("successfulAuctions")}
        guard let joinedSince = dto.joinedSince else {throw VendorAuctionDetailError.missingValue("joinedSince")}
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.successfulAuctions = successfulAuctions
        self.joinedSince = joinedSince
        self.geoLocation = dto.geoLocation
        self.webSiteUrl = dto.webSiteUrl
        self.shortBio = dto.shortBio
    }
    
    internal init(id: UUID, name: String, username: String, email: String, successfulAuctions: Int, joinedSince: Date, geoLocation: String? = nil, webSiteUrl: String? = nil, shortBio: String? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.successfulAuctions = successfulAuctions
        self.joinedSince = joinedSince
        self.geoLocation = geoLocation
        self.webSiteUrl = webSiteUrl
        self.shortBio = shortBio
    }
}
