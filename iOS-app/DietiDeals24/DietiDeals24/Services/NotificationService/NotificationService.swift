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
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case creationDate
        case message
        case mainImageUrl
        case auctionId
        case auctionTitle
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.type = try container.decodeIfPresent(NotificationType.self, forKey: .type)
        let creationDateString = try container.decodeIfPresent(String.self, forKey: .creationDate)
        if let creationDateString = creationDateString {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = formatter.date(from: creationDateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .creationDate,
                    in: container,
                    debugDescription: "Invalid date format: \(creationDateString)"
                )
            }
            self.creationDate = date
        } else {
            self.creationDate = nil
        }
        
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.mainImageUrl = try container.decodeIfPresent(String.self, forKey: .mainImageUrl)
        self.auctionId = try container.decodeIfPresent(UUID.self, forKey: .auctionId)
        self.auctionTitle = try container.decodeIfPresent(String.self, forKey: .auctionTitle)
    }
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
