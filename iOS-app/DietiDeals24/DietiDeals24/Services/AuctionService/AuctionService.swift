//
//  AuctionService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

/// A service responsible for fetching auction-related data.
protocol AuctionService {
    /// Fetches a paginated list of auctions based on the given filters and search query.
    ///
    /// - Parameters:
    ///   - filters: Optional filters to apply when retrieving auctions (e.g., category, auction type ).
    ///   - page: The page number to fetch.
    ///   - pageSize: The number of items per page.
    /// - Returns: A `PaginatedResult` containing a list of `AuctionCardModel` objects and pagination metadata.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    func fetchAuctions(
        filters: SearchFilterModel,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedResult<AuctionCardDTO>

    /// Fetches the details of a specific auction.
    ///
    /// - Parameter id: The unique identifier (UUID) of the auction.
    /// - Returns: An `Auction` object containing detailed information about the auction.
    /// - Throws: An error if the request fails or the auction is not found.
    func fetchAuctionDetails(by id: UUID) async throws -> AuctionDetailDTO
    
    /// Sends the details of a newly created auction and returns it.
    ///
    /// - Parameter auction: the model of the compiled form.
    /// - Returns: An `Auction` object containing detailed information about the auction.
    /// - Throws: An error if the request fails.
    func createAuction(auction: CreateAuctionModel, vendor: UUID) async throws -> AuctionDetailDTO
    
    
}

enum AuctionServiceError: LocalizedError {
    case notFound
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
            case .notFound:
                return "Auction not found."
            case .unknown(let message):
                return "Unknown error: \(message)"
        }
    }
}
