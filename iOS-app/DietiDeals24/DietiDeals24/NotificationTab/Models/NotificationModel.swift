//
//  NotificationModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

import Foundation

struct NotificationModel: Identifiable {
    
    var id: UUID
    var title: String
    var message: String
    var date: Date
    var auctionId: UUID
    var auctionName: String
    var imageUrl: String
    
    init(id: UUID, title: String, message: String, date: Date, auctionId: UUID, auctionName: String, imageUrl: String) {
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.auctionId = auctionId
        self.auctionName = auctionName
        self.imageUrl = imageUrl
    }
    
    
    init (from dto: NotificationDTO) {
        
        self.id = dto.id ?? UUID()
        self.title = dto.type?.title ?? ""
        self.message = dto.message ?? ""
        self.date = dto.creationDate ?? .distantPast
        self.auctionId = dto.auctionId ?? UUID()
        self.auctionName = dto.auctionTitle ?? ""
        self.imageUrl = dto.mainImageUrl ?? ""
    }
}
