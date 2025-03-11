//
//  AuctionEndpoint.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

enum AuctionEndpoint {
    case auctionList(filters: SearchFilterModel, page: Int, pageSize: Int)
    case auctionDetail(id: UUID)
    case createAuction(auction: CreateAuctionModel, vendorId: UUID)
    case loadImage(url: String, data: Data)
}

extension AuctionEndpoint {
    
    var endpoint: EndpointConvertible {
        switch self {
            case .auctionList(let filters, let page, let pageSize):
                return Self.AuctionListEndpoint(filters: filters, page: page, pageSize: pageSize)
            case .auctionDetail(let id):
                return Self.AuctionDetailEndpoint(id: id)
            case .createAuction(let auction, let vendorId):
                return Self.CreateAuctionEndpoint(auction: auction, vendorId: vendorId)
            case .loadImage(url: let url, data: let data):
                return Self.loadImage(url: url, data: data)
        }
    }
    
    static private func AuctionListEndpoint(filters: SearchFilterModel, page: Int, pageSize: Int) -> CodableEndpoint<PaginatedResult<AuctionCardDTO>>  {
        
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let body = AuctionListRequestBody(
            page: page,
            size: pageSize,
            searchText: filters.serchTerm,
            category: filters.activeCategoryFilter != .all ? filters.activeCategoryFilter : nil,
            type: filters.activeAuctionTypeFilter != .all ? filters.activeAuctionTypeFilter : nil,
            order: filters.activeSortOrderFilter != .relevance ? filters.activeSortOrderFilter : nil,
            minPrice: filters.activePriceRangeFilter?.min,
            maxPrice: filters.activePriceRangeFilter?.max,
            vendorId: filters.vendorIdFilter
        ).jsonObject
        
        return CodableEndpoint<PaginatedResult<AuctionCardDTO>>(
            Endpoint(
                baseURL: baseURLString,
                path: "/Auction/get-paginated-auctions",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
    
    static private func AuctionDetailEndpoint(id: UUID) -> CodableEndpoint<AuctionDetailDTO>  {
        
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.get
        
        return CodableEndpoint<AuctionDetailDTO>(
            Endpoint(
                baseURL: baseURLString,
                path: "Auction/get-detailed-auction-by-id",
                queryParameters: ["id" : id.uuidString],
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
    
    
    static private func CreateAuctionEndpoint(auction: CreateAuctionModel, vendorId: UUID) -> CodableEndpoint<CreateAuctionResponseDTO>  {
        let baseURLString = URL(string: NetworkConfiguration.backendBaseUrl)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let body = CreateAuctionDTO(from: auction, vendorId: vendorId).jsonObject
        
        return CodableEndpoint<CreateAuctionResponseDTO>(
            Endpoint(
                baseURL: baseURLString,
                path: "/Auction/create-auction",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                authorizationType: .bearer
            )
        )
    }
    
    static private func loadImage(url: String, data: Data) -> Endpoint  {
        let httpMethod: HTTPMethod = .put
        let encoding = Endpoint.Encoding.custom("image/jpeg")
        
        return Endpoint(
                baseURL: URL(string: url)!,
                path: "",
                dataBody: data,
                encoding: encoding,
                method: httpMethod
            
        )
    }
}
