//
//  DefaultAuctionService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

final class DefaultAuctionService: AuctionService {
    
    let rest: RESTDataSource
    
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func fetchAuctions(filters: SearchFilterModel, page: Int, pageSize: Int) async throws -> PaginatedResult<AuctionCardDTO> {
        let response: PaginatedResult<AuctionCardDTO> = try await rest.getCodable(at: AuctionEndpoint.auctionList(filters: filters, page: page, pageSize: pageSize).endpoint)
        
        return response
    }
    
    func fetchAuctionDetails(by id: UUID) async throws -> AuctionDetailDTO {
        let response: AuctionDetailDTO = try await rest.getCodable(at: AuctionEndpoint.auctionDetail(id: id).endpoint)
        
        return response
    }
    
    func createAuction(auction: CreateAuctionModel, vendor: UUID) async throws -> AuctionDetailDTO {
        let response: CreateAuctionResponseDTO = try await rest.getCodable(at: AuctionEndpoint.createAuction(auction: auction, vendorId: vendor).endpoint)
        guard let detailedAuction = response.detailedAuction else {
            throw AuctionServiceError.unknown("Could not create auction")
        }
        
        if let preSignedDict = response.imagesPreSignedUrls {
            try? await sendImagesToS3( preSignedDict, imageData: auction.baseDetail.imagesPreview.compactMap({ preview in
                guard case .success(let auctionImage) = preview else {
                    return nil
                }
                return auctionImage
            }))
        }
        
        return detailedAuction
    }
    
    private func sendImagesToS3(_ preSignedDict: [UUID: String], imageData: [AuctionImage]) async throws {
        await withTaskGroup(of: Void.self) { group in
                    for (imageId, presignedUrl) in preSignedDict {
                        guard let auctionImage = imageData.first(where: {$0.identifier == imageId}) else {
                            print("missing data for image id \(imageId)")
                            continue
                        }

                        group.addTask {
                            print("LOADING IMAGE \(auctionImage.identifier) TO S3 with URL \(presignedUrl)")
                            try? await self.uploadImageAt(presignedUrl, data: auctionImage.data)
                        }
                    }
                }
    }
    
    private func uploadImageAt(_ url: String, data: Data) async throws {
        let _ = try await rest.getData(at: AuctionEndpoint.loadImage(url: url, data: data).endpoint)
    }
    
}
