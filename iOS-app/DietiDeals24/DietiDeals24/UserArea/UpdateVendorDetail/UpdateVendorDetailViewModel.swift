//
//  BecomeAVendorViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

@Observable
class UpdateVendorDetailViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var userAreaCoordinator: UserAreaCoordinator
    
    var vendorID: UUID?
    var shortBio: String = ""
    var url: String = ""
    var geoLocation: String = ""
    
    let vendorService: VendorService
    
    init(userAreaCoordinator: UserAreaCoordinator, vendorService: VendorService) {
        self.userAreaCoordinator = userAreaCoordinator
        self.vendorService = vendorService
    }
    
    func setupDetails(vendorId: UUID, shortBio: String, url: String, geoLocation: String) {
        self.vendorID = vendorId
        self.shortBio = shortBio
        self.url = url
        self.geoLocation = geoLocation
    }
    
    @MainActor
    func dismiss(shouldReloadUserData: Bool = false) {
        userAreaCoordinator.dismiss()
    }
    
    @MainActor
    func submitUpdateVendorDetail() {
        Task {
            guard let uuid = self.vendorID else {return}
            isLoading = true
            defer {
                isLoading = false
            }
            let _ = try await vendorService.updateVendorProfile(update: UpdateVendorBodyRequest(vendorId: uuid, shortBio: self.shortBio, webSiteUrl: self.url, geoLocation: self.geoLocation))
            
            dismiss()
        }
    }
    
    
}
