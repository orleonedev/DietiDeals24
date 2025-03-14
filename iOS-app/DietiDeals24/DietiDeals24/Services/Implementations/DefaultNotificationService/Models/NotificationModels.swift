//
//  NotificationModels.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/12/25.
//

import Foundation

struct RegisterTokenBody: Encodable, BodyParameters {
    let userId: UUID?
    let deviceToken: String?
    
    enum CodingKeys: CodingKey {
        case userId
        case deviceToken
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.deviceToken, forKey: .deviceToken)
    }
    
}

struct NotificationsRequestBody: Encodable, BodyParameters {
    let userId: UUID
    let page: Int
    let pageSize: Int
    
    enum CodingKeys: CodingKey {
        case userId
        case page
        case pageSize
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageSize, forKey: .pageSize)
    }
    
}
