//
//  UserProfileViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/6/25.
//

import SwiftUI

@Observable
class UserProfileViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    
    var userDataModel: UserDataModel? = nil
    var auctionsFilters: SearchFilterModel = SearchFilterModel()
    
    var vendorItems: [AuctionCardModel] = []
    var vendorItemsCount: Int = 0
    var vendorPage: Int = 1
    var vendorPageSize: Int = 20
    var isFetchingVendorItems: Bool = false
    var shouldFetchMoreVendorItem: Bool = true
    
    let coordinator: UserProfileCoordinatorProtocol
    let auctionService: AuctionService
    
    init( coordinator: UserProfileCoordinatorProtocol, auctionService: AuctionService) {
        self.coordinator = coordinator
        self.auctionService = auctionService
    }
    
    func setVendor(_ vendor: VendorProfileResponseDTO) {
        self.userDataModel = UserDataModel(
            name: vendor.name ?? "",
            username: vendor.username ?? "",
            email: vendor.email ?? "",
            role: .seller,
            userID: nil,
            vendorId: vendor.id?.uuidString,
            shortBio: vendor.shortBio,
            url: vendor.webSiteUrl,
            auctionCreated: vendor.successfulAuctions,
            joinedSince: vendor.joinedSince,
            geoLocation: vendor.geoLocation
        )
        self.auctionsFilters = SearchFilterModel(vendorIdFilter: vendor.id)
    }
    
    func getAuctionDetail(_ auctionID: UUID) {
        Task {
            print(auctionID)
            self.isLoading = true
            
            let auctionDTO = try await auctionService.fetchAuctionDetails(by: auctionID)
            let model = try AuctionDetailModel(from: auctionDTO)
            
            self.isLoading = false
            await self.coordinator.goToAuction(model)
            
        }
    }
    
    @MainActor
    func getMoreVendorItems() {
        Task {
            guard shouldFetchMoreVendorItem, !isFetchingVendorItems else { return }
            isFetchingVendorItems = true
            defer {
                self.isFetchingVendorItems = false
                self.isLoading = false
            }
            let vendorItemsDto = try await auctionService.fetchAuctions(filters: self.auctionsFilters, page: self.vendorPage, pageSize: self.vendorPageSize)
            let newVendorItems: [AuctionCardModel] = vendorItemsDto.results.compactMap {try? AuctionCardModel(from: $0)}
            self.vendorPage = vendorItemsDto.pageNumber+1
            self.vendorItemsCount = vendorItemsDto.totalRecords
            self.vendorItems.append(contentsOf: newVendorItems)
            self.shouldFetchMoreVendorItem = vendorItemsCount > vendorItems.count
        }
    }
    
}
