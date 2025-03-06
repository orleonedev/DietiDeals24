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
    let successfulAuctions: Int?
    let joinedSince: Date?
    let geoLocation: String?
    let websiteUrl: String?
    let shortBio: String?
    
    enum CodingKeys: String, CodingKey {
        case vendorID
        case vendorName
        case vendorUsername
        case vendorEmail
        case successfulAuctions
        case joinedSince
        case geoLocation
        case websiteUrl
        case shortBio
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.vendorID = try container.decodeIfPresent(UUID.self, forKey: .vendorID)
        self.vendorName = try container.decodeIfPresent(String.self, forKey: .vendorName)
        self.vendorUsername = try container.decodeIfPresent(String.self, forKey: .vendorUsername)
        self.vendorEmail = try container.decodeIfPresent(String.self, forKey: .vendorEmail)
        self.successfulAuctions = try container.decodeIfPresent(Int.self, forKey: .successfulAuctions)
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
        
        self.geoLocation = try container.decodeIfPresent(String.self, forKey: .geoLocation)
        self.websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
        self.shortBio = try container.decodeIfPresent(String.self, forKey: .shortBio)
    }
    
    init(vendorID: UUID? = nil, vendorName: String? = nil, vendorUsername: String? = nil, vendorEmail: String? = nil, successfulAuctions: Int? = nil, joinedSince: Date? = nil, geoLocation: String? = nil, websiteUrl: String? = nil, shortBio: String? = nil) {
        self.vendorID = vendorID
        self.vendorName = vendorName
        self.vendorUsername = vendorUsername
        self.vendorEmail = vendorEmail
        self.successfulAuctions = successfulAuctions
        self.joinedSince = joinedSince
        self.geoLocation = geoLocation
        self.websiteUrl = websiteUrl
        self.shortBio = shortBio
    }
}
