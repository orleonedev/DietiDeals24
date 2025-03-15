//
//  UserAreaMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//
import SwiftUI

@Observable
class UserAreaMainViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var coordinator: UserAreaCoordinator
    var userDataModel: UserDataModel? = nil
    
    var auctionsFilters: SearchFilterModel = SearchFilterModel()
    var vendorItems: [AuctionCardModel] = []
    var vendorItemsCount: Int = 0
    var vendorPage: Int = 1
    var vendorPageSize: Int = 20
    var isFetchingVendorItems: Bool = false
    var shouldFetchMoreVendorItem: Bool = true
    
    
    let vendorService: VendorService
    let auctionService: AuctionService
    init(coordinator: UserAreaCoordinator, vendorService: VendorService, auctionService: AuctionService) {
        self.coordinator = coordinator
        self.vendorService = vendorService
        self.auctionService = auctionService
    }
    
    func getUserData() async {
        isLoading = true
        var user = await coordinator.getUserData()
        if let unwrap = user, unwrap.role == .seller, let sellerId = unwrap.vendorId, let uuid = UUID(uuidString: sellerId) {
            let vendorDetail = try? await vendorService.getVendorProfile(id: uuid)
            user?.geoLocation = vendorDetail?.geoLocation
            user?.joinedSince = vendorDetail?.joinedSince
            user?.url = vendorDetail?.webSiteUrl
            user?.successfulAuctions = vendorDetail?.successfulAuctions
            user?.shortBio = vendorDetail?.shortBio
            user?.vendorId = vendorDetail?.id?.uuidString
            self.auctionsFilters = SearchFilterModel(vendorIdFilter: vendorDetail?.id)
        }
        self.userDataModel = user
        isLoading = false
    }
    
    func logout() {
        Task {
            isLoading = true
            await self.coordinator.logout()
            isLoading = false
        }
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
    func refreshVendorItems() {
        vendorItems.removeAll()
        vendorItemsCount = 0
        vendorPage = 1
        shouldFetchMoreVendorItem = true
        getMoreVendorItems()
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
