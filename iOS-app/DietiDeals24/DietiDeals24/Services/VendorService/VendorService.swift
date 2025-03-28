//
//  VendorService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

protocol VendorService {
    
    func becomeAVendor(parameters: BecomeAVendorBodyRequest) async throws -> Bool
    
    func getVendorProfile(id: UUID) async throws -> VendorProfileResponseDTO
    
    func updateVendorProfile(update: UpdateVendorBodyRequest) async throws -> VendorProfileResponseDTO
}
