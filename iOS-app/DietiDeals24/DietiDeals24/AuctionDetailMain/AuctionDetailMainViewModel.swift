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
    let auctionService: AuctionService
    init(auctionCoordinator: AuctionCoordinatorProtocol, vendorService: VendorService, auctionService: AuctionService) {
        self.auctionCoordinator = auctionCoordinator
        self.vendorService = vendorService
        self.auctionService = auctionService
    }
    
    var auction: AuctionDetailModel?
    var isPersonalAcution: Bool = false
    
    func setAuction(_ auction: AuctionDetailModel) {
        self.auction = auction
    }
    
    @MainActor
    func checkAuctionOwnership() {
        guard let auction = self.auction else { return }
        Task {
            guard let userData = await auctionCoordinator.getUserData() else { return }
            self.isPersonalAcution = userData.vendorId == auction.vendor.id.uuidString.lowercased()
        }
    }
    
    @MainActor
    func showPresentOfferSheet() {
        guard let auction = self.auction else { return }
        auctionCoordinator.showPresentOfferSheet(for: auction) {[weak self] status in
            guard let self = self else { return }
            self.dismissSheet()
            if status {
                self.reloadAuction()
            }
        }
    }
    
    @MainActor
    private func dismissSheet() {
        auctionCoordinator.router.dismiss()
    }
    
    @MainActor
    func reloadAuction() {
        guard let auctionID = self.auction?.id else { return }
        Task {
            defer {
                self.isLoading = false
            }
            do {
                self.isLoading = true
                let auctionDTO = try await auctionService.fetchAuctionDetails(by: auctionID)
                let model = try AuctionDetailModel(from: auctionDTO)
                self.auction = model
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func showVendorProfile(id vendorID: UUID) {
        print(vendorID.uuidString)
        guard let auction = self.auction else { return }
        Task {
            self.isLoading = true
            
//            let auctionDTO = try await auctionService.fetchAuctionDetails(by: auctionID)
//            let model = try AuctionDetailModel(from: auctionDTO)
//            
            self.isLoading = false
            self.auctionCoordinator.goToVendor(auction.vendor)
            
        }
    }
    
    
}
