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
}
