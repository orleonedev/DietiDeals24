//
//  AuctionDetailMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

@Observable
class AuctionDetailMainViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    let auctionCoordinator: AuctionCoordinatorProtocol
    let vendorService: VendorService
    
    init(auctionCoordinator: AuctionCoordinatorProtocol, vendorService: VendorService) {
        self.auctionCoordinator = auctionCoordinator
        self.vendorService = vendorService
    }
    
    var auction: AuctionDetailModel?
    var canPresentOffer: Bool = false
    
    func setAuction(_ auction: AuctionDetailModel) {
        self.auction = auction
    }
    
    @MainActor
    func checkAuctionOwnership() {
        guard let auction = self.auction else { return }
        Task {
            guard let userData = await auctionCoordinator.getUserData() else { return }
            self.canPresentOffer = userData.vendorId != auction.vendorID.uuidString.lowercased()
        }
    }
    
    @MainActor
    func showPresentOfferSheet() {

    }
    
    @MainActor
    func showVendorProfile(id vendorID: UUID) {
        print(vendorID.uuidString)
        Task {
            self.isLoading = true
            
//            let auctionDTO = try await auctionService.fetchAuctionDetails(by: auctionID)
//            let model = try AuctionDetailModel(from: auctionDTO)
//            
            self.isLoading = false
            self.auctionCoordinator.goToVendor(VendorProfileResponseDTO(
                vendorID: vendorID,
                vendorName: "Vendor Name",
                vendorUsername: "vendorUsername",
                vendorEmail: "vendor.email@email.com",
                numberOfAuctions: 0,
                joinedSince: Date.now,
                geolocation: "Napoli",
                websiteUrl: "chill.com",
                shortBio: "un ragazzo nel chill"
            ) )
            
        }
    }
    
    
}
