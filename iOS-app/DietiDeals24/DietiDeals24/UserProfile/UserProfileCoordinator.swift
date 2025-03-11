//
//  UserProfileCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/6/25.
//

import RoutingKit

internal protocol UserProfileCoordinatorProtocol: Coordinator {
    
    var router: Router { get }
    
    @MainActor
    func getUserData() async -> UserDataModel?
    
    @MainActor
    func goToAuction(_ auction: AuctionDetailModel)
    func auctionDetailDestination(_ auction: AuctionDetailModel) -> RoutingKit.Destination
    
    
}

extension UserProfileCoordinatorProtocol {
    
    @MainActor
    func goToAuction(_ auction: AuctionDetailModel) {
        self.router.navigate(to: auctionDetailDestination(auction), type: .push)
    }
    
}

internal protocol AuctionCoordinatorProtocol: Coordinator {
    
    var router: Router { get }
    
    @MainActor
    func getUserData() async -> UserDataModel?
    
    @MainActor
    func goToVendor(_ vendor: VendorAuctionDetail)
    func vendorProfileDestination(_ vendor: VendorAuctionDetail) -> RoutingKit.Destination
    
    @MainActor
    func showPresentOfferSheet(for auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)? )
    func presentOfferSheetDestination(for auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)? ) -> RoutingKit.Destination
    
}

extension AuctionCoordinatorProtocol {
    
    @MainActor
    func goToVendor(_ vendor: VendorAuctionDetail) {
        self.router.navigate(to: vendorProfileDestination(vendor), type: .push)
    }
    
    @MainActor
    func showPresentOfferSheet(for auction: AuctionDetailModel, onBidResult: ((Bool) -> Void)? = nil) {
        self.router.navigate(to: presentOfferSheetDestination(for: auction, onBidResult: onBidResult), type: .sheet)
    }
    
}
