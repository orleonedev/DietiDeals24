//
//  AuctionPreviewViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

@Observable
class AuctionPreviewViewModel: LoadableViewModel {
    var isLoading: Bool = false
    
    var sellingCoordinator: SellingCoordinator
    var auction: CreateAuctionModel?
    var auctionService: AuctionService
    init(sellingCoordinator: SellingCoordinator, auctionService: AuctionService) {
        self.sellingCoordinator = sellingCoordinator
        self.auctionService = auctionService
    }
    
    public func setAuction(_ auction: CreateAuctionModel) {
        self.auction = auction
    }
    
    @MainActor
    func tryToDismiss() {
        self.sellingCoordinator.dismiss()
    }
    
    @MainActor
    func publishAuction() {
        Task {
            guard let auction = self.auction, let userData = await sellingCoordinator.getUserData(), let vendorId = userData.vendorId, let uuid = UUID(uuidString: vendorId) else { return }
            self.isLoading = true
            let auctioDTO = try await auctionService.createAuction(auction: auction, vendor: uuid)
            let auctioCreated = try AuctionDetailModel(from: auctioDTO)
            self.isLoading = false
            self.sellingCoordinator.goToPublishedAuction(auction: auctioCreated)
        }
    }
    
}
