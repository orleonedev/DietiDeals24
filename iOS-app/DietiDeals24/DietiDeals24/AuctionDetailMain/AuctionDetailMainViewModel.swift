//
//  AuctionDetailMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

@Observable
class AuctionDetailMainViewModel: LoadableViewModel {
    
    enum Owner {
        case Selling
        case Explore
        case Search
    }
    
    var isLoading: Bool = false
    let owner: Owner
    var sellingCoordnator: SellingCoordinator?
    var exploreCoordinator: ExploreCoordinator?
    var searchCoordinator: SearchCoordinator?
    
    var auction: AuctionDetailModel?
    var canPresentOffer: Bool = true
    
    init(sellingCoordinator: SellingCoordinator) {
        self.sellingCoordnator = sellingCoordinator
        self.owner = .Selling
    }
    
    init (exploreCoordinator: ExploreCoordinator) {
        self.exploreCoordinator = exploreCoordinator
        self.owner = .Explore
    }
    
    init (searchCoordinator: SearchCoordinator) {
        self.searchCoordinator = searchCoordinator
        self.owner = .Search
    }
    
    func setAuction(_ auction: AuctionDetailModel) {
        self.auction = auction
    }
    
    @MainActor
    func showPresentOfferSheet() {
//        switch owner {
//            case .Selling:
//                sellingCoordnator?.showPresentOfferSheet()
//            case .Explore:
//                exploreCoordinator?.showPresentOfferSheet()
//            case .Search:
//                searchCoordinator?.showPresentOfferSheet()
//        }
    }
    
    @MainActor
    func showVendorProfile(id vendorID: UUID) {
        print(vendorID.uuidString)
        //        switch owner {
        //            case .Selling:
        //                sellingCoordnator?.showVendorProfile(id: id)
        //            case .Explore:
        //                exploreCoordinator?.showVendorProfile(id: id)
        //            case .Search:
        //                searchCoordinator?.showVendorProfile(id: id)
        //        }
    }
    
    
}
