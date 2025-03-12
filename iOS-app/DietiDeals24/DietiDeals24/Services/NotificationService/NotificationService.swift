//
//  NotificationService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

import Foundation

protocol NotificationService {
    
    func getNotifications(page: Int, pageSize: Int, userId: UUID) async throws -> PaginatedResult<NotificationDTO>
    
    func registerForRemoteNotifications(with deviceToken: String, forUser userId: UUID) async throws
    
    func unregisterForRemoteNotifications() async throws
}

struct NotificationDTO: Decodable {
    
    var id: UUID?
    var type: NotificationType?
    var creationDate: Date?
    var message: String?
    var mainImageUrl: String?
    var auctionId: UUID?
    var auctionTitle: String?
}

enum NotificationType: Int, Decodable {
    case auctionExpired = 0, auctionBid = 1, auctionClosed = 2
    
    var title: String {
        switch self {
            case .auctionExpired:
                return "Auction expired"
            case .auctionBid:
                return "New Bid"
            case .auctionClosed:
                return "Auction Closed"
        }
    }
}
