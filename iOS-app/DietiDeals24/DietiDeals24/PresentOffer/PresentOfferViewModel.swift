//
//  PresentOfferViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/7/25.
//

import SwiftUI

@Observable
class PresentOfferViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var auctionDetails: AuctionDetailModel?
    
    var auctionCoordinator: AuctionCoordinatorProtocol
    let bidService: BidService
    var onBidResult: ((Bool) -> Void)?
    
    var bidPriceString: String = "" {
        didSet {
            if let type = auctionDetails?.auctionType, type == .incremental {
                self.bidPrice = Double(bidPriceString)
            }
        }
    }
    private var bidPrice: Double?
    
    var priceValidationError: Bool = false
    
    init(auctionCoordinator: AuctionCoordinatorProtocol, bidService: BidService) {
        self.auctionCoordinator = auctionCoordinator
        self.bidService = bidService
    }
    
    func setAuctionDetials(_ auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)? = nil) {
        self.auctionDetails = auction
        self.onBidResult = onBidResult
        if auction.auctionType == .descending {
            self.bidPrice = auction.currentPrice
        }
    }
    
    func validatePrice() {
        
        guard let auctionDetails = self.auctionDetails, auctionDetails.auctionType == .incremental else { self.priceValidationError = false; return }
        self.priceValidationError = (Double(bidPriceString) ?? 0.0) < (auctionDetails.currentPrice + auctionDetails.threshold)
    }
    
    @MainActor
    func submitBid() {
        Task {
            validatePrice()
            guard priceValidationError == false, let auction = self.auctionDetails, let userData = await auctionCoordinator.getUserData(), let userUUID = UUID(uuidString: userData.userID ?? ""), let bidPrice = self.bidPrice else { return }
            do {
                self.isLoading = true
                let _ = try await bidService.sendBid(bid: AuctionBidDTO(auctionId: auction.id, buyerId: userUUID, price: bidPrice))
                self.isLoading = false
                onBidResult?( true)
            } catch {
                self.isLoading = false
                onBidResult?( false)
            }
        }
    }
    
    @MainActor
    func dismiss() {
        auctionCoordinator.router.dismiss()
    }
    
}
