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
    var url: String = ""
    var geoLocation: String = ""
}
