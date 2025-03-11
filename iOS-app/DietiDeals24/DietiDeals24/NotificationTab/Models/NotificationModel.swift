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
}
