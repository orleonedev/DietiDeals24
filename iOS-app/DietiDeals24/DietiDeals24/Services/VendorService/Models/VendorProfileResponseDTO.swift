//
//  Untitled.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

import Foundation

struct VendorProfileResponseDTO: Decodable {
    let id: UUID?
    let name: String?
    let username: String?
    let email: String?
    let successfulAuctions: Int?
    let joinedSince: Date?
    let geoLocation: String?
    let webSiteUrl: String?
    let shortBio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
        case successfulAuctions
        case joinedSince
        case geoLocation
        case webSiteUrl
        case shortBio
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.successfulAuctions = try container.decodeIfPresent(Int.self, forKey: .successfulAuctions)
        let joinedString = try container.decodeIfPresent(String.self, forKey: .joinedSince)
        if let joinedString = joinedString {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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
        
        self.geoLocation = try container.decodeIfPresent(String.self, forKey: .geoLocation)
        self.webSiteUrl = try container.decodeIfPresent(String.self, forKey: .webSiteUrl)
        self.shortBio = try container.decodeIfPresent(String.self, forKey: .shortBio)
    }
    
    init(vendorID: UUID? = nil, vendorName: String? = nil, vendorUsername: String? = nil, vendorEmail: String? = nil, successfulAuctions: Int? = nil, joinedSince: Date? = nil, geoLocation: String? = nil, websiteUrl: String? = nil, shortBio: String? = nil) {
        self.id = vendorID
        self.name = vendorName
        self.username = vendorUsername
        self.email = vendorEmail
        self.successfulAuctions = successfulAuctions
        self.joinedSince = joinedSince
        self.geoLocation = geoLocation
        self.webSiteUrl = websiteUrl
        self.shortBio = shortBio
    }
}
