//
//  Untitled.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

import Foundation

struct VendorProfileResponseDTO: Decodable {
    let vendorID: UUID?
    let vendorName: String?
    let vendorUsername: String?
    let vendorEmail: String?
    let numberOfAuctions: Int?
    let joinedSince: Date?
    let geolocation: String?
    let websiteUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case vendorID
        case vendorName
        case vendorUsername
        case vendorEmail
        case numberOfAuctions
        case joinedSince
        case geolocation
        case websiteUrl
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.vendorID = try container.decodeIfPresent(UUID.self, forKey: .vendorID)
        self.vendorName = try container.decodeIfPresent(String.self, forKey: .vendorName)
        self.vendorUsername = try container.decodeIfPresent(String.self, forKey: .vendorUsername)
        self.vendorEmail = try container.decodeIfPresent(String.self, forKey: .vendorEmail)
        self.numberOfAuctions = try container.decodeIfPresent(Int.self, forKey: .numberOfAuctions)
        let joinedString = try container.decodeIfPresent(String.self, forKey: .joinedSince)
        if let joinedString = joinedString {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = dateFormatter.date(from: joinedString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .joinedSince,
                    in: container,
                    debugDescription: "Invalid date format: \(joinedString)"
                )
            }
            self.joinedSince = date
        } else {
            self.joinedSince = nil
        }
        
        self.geolocation = try container.decodeIfPresent(String.self, forKey: .geolocation)
        self.websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
    }
}
