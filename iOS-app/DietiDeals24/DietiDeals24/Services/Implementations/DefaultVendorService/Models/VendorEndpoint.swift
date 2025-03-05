//
//  VendorEndpoint.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/5/25.
//

import Foundation

enum VendorEndpoint {
    case becomeVendor(parameters: BecomeAVendorBodyRequest)
    case getVendor(id: UUID)
}

extension VendorEndpoint: EndpointConvertible {
    var endpoint: Endpoint {
        switch self {
            case .becomeVendor(let parameters):
                return Self.getBecomeAVendorEndpoint(param: parameters).endpoint
            case .getVendor(let id):
                return Self.getVendorDetailEndpoint(id: id).endpoint
        }
    }
    
    static private func getBecomeAVendorEndpoint(param: BecomeAVendorBodyRequest) -> CodableEndpoint<Bool> {
        
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let body = param.jsonObject
        
        return CodableEndpoint<Bool>(
            Endpoint(
                baseURL: baseURLString,
                path: "/Vendor/become-a-vendor",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
    
    static private func getVendorDetailEndpoint(id: UUID) -> CodableEndpoint<VendorProfileResponseDTO> {
        
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.get
        
        return CodableEndpoint<VendorProfileResponseDTO>(
            Endpoint(
                baseURL: baseURLString,
                path: "Vendor/get-vendor-by-id",
                queryParameters: ["id" : id.uuidString],
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
}
