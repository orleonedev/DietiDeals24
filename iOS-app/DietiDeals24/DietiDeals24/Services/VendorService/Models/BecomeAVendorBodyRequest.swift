//
//  BecomeAVendorBodyRequest.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

struct BecomeAVendorBodyRequest: Encodable, BodyParameters {
    var userId: UUID
    var shortBio: String = ""
    var webSiteUrl: String = ""
    var geoLocation: String = ""
}

struct UpdateVendorBodyRequest: Encodable, BodyParameters {
    var vendorId: UUID
    var shortBio: String = ""
    var webSiteUrl: String = ""
    var geoLocation: String = ""
}
