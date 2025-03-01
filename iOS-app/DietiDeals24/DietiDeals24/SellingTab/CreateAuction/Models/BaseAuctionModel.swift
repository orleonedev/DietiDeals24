//
//  BaseAuctionModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

struct CreateBaseAuctionModel {
    var title: String
    var description: String
    var category: AuctionCategory?
    var images: [String] = []
}

struct CreateAuctionModel {
    var baseDetail: CreateBaseAuctionModel
    var auctionType: AuctionType = .incremental
    var startingPrice: Double = 0.0
    var threshold: Double = 1.0
    var timer: Int = 1
    var secretPrice: Double?
}
