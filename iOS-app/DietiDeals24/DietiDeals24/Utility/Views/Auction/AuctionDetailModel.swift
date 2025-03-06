//
//  AuctionDetailModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import Foundation

struct AuctionDetailModel {
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
    var vendor: VendorProfileResponseDTO
}

struct VendorAuctionDetail {
    var id: UUID?
    var name: String?
    var username: String?
    var email: String?
    var successfulAuctions: Int?
    var joinedSince: Date?
    var geoLocation: String?
    var webSiteUrl: String?
    var shortBio: String?
}
