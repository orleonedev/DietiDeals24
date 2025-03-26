//
//  DefaultVendorService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

import Foundation

final class DefaultVendorService: VendorService {
    func updateVendorProfile(update: UpdateVendorBodyRequest) async throws -> VendorProfileResponseDTO {
        let updatedProfile: VendorProfileResponseDTO = try await rest.getCodable(at: VendorEndpoint.updateVendorDetail(update: update).endpoint)
        return updatedProfile
    }
    
    
    let rest: RESTDataSource
    
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func becomeAVendor(parameters: BecomeAVendorBodyRequest) async throws -> Bool {
        let _: VendorProfileResponseDTO = try await rest.getCodable(at: VendorEndpoint.becomeVendor(parameters: parameters).endpoint)
        
        return true
    }
    
    func getVendorProfile(id: UUID) async throws -> VendorProfileResponseDTO {
        let response: VendorProfileResponseDTO = try await rest.getCodable(at: VendorEndpoint.getVendor(id: id).endpoint)
        return response
    }
    
    
}
