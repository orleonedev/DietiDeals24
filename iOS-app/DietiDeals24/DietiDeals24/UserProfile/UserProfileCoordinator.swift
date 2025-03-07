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
    
//    func auctionDetailDestination(_ auction: AuctionDetailModel) -> RoutingKit.Destination {
//        .init {
//            let vm = self.appContainer.unsafeResolve(AuctionDetailMainViewModel.self, tag: .init("Explore"))
//            vm.setAuction(auction)
//            return AuctionDetailMainView(viewModel: vm)
//            
//        }
//    }
}

internal protocol AuctionCoordinatorProtocol: Coordinator {
    
    var router: Router { get }
    
    @MainActor
    func getUserData() async -> UserDataModel?
    
    @MainActor
    func goToVendor(_ vendor: VendorProfileResponseDTO)
    func vendorProfileDestination(_ vendor: VendorProfileResponseDTO) -> RoutingKit.Destination
    
}

extension AuctionCoordinatorProtocol {
    
    @MainActor
    func goToVendor(_ vendor: VendorProfileResponseDTO) {
        self.router.navigate(to: vendorProfileDestination(vendor), type: .push)
    }
    
    
}
