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
    let vendorService: VendorService
    init(coordinator: UserAreaCoordinator, vendorService: VendorService) {
        self.coordinator = coordinator
        self.vendorService = vendorService
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
}
