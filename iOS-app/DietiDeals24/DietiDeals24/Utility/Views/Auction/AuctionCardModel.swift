//
//  AuctionCardModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//

import Foundation

struct AuctionCardModel: Identifiable {
    var id: UUID
    var name: String
    var price: String
    var coverUrl: String
    var auctionType: AuctionType
    var bidsCount: Int
    var endTime: Date
}

extension AuctionCardModel {
    
    static var mockData : [AuctionCardModel] {(0...40).map { (index: Int) in
        return AuctionCardModel(
            id: UUID(),
            name: "Rick Roll",
            price: "1000",
            coverUrl: "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f",
            auctionType: index % 3 == 0 ? .descending : .incremental,
            bidsCount: index % 3 != 0 ? index : 0,
            endTime: .now.advanced(by: 60*15+Double(index*3))
        )
    }
    }
    
}
