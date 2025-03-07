//
//  BecomeAVendorViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

@Observable
class BecomeAVendorViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var sellingCoordinator: SellingCoordinator
    
    var shortBio: String = ""
    var url: String = ""
    var geoLocation: String = ""
    
    let vendorService: VendorService
    
    init(sellingCoordinator: SellingCoordinator, vendorService: VendorService) {
        self.sellingCoordinator = sellingCoordinator
        self.vendorService = vendorService
    }
    
    @MainActor
    func dismiss(shouldReloadUserData: Bool = false) {
        sellingCoordinator.dismiss(shouldReloadUserData: shouldReloadUserData)
    }
    
    @MainActor
    func submitVendorDetail() {
        Task {
            guard let user = await sellingCoordinator.getUserData(), let idString = user.userID, let uuid = UUID(uuidString: idString) else {return}
            isLoading = true
            defer {
                isLoading = false
            }
            let response = try await vendorService.becomeAVendor(parameters: .init(userId: uuid, shortBio: shortBio, webSiteUrl: url, geoLocation: geoLocation))
            
            dismiss(shouldReloadUserData: response )
        }
    }
    
    @MainActor
    func skipSubmitVendorDetail() {
        Task {
            guard let user = await sellingCoordinator.getUserData(), let idString = user.userID, let uuid = UUID(uuidString: idString) else {return}
            isLoading = true
            defer {
                isLoading = false
            }
            let response = try await vendorService.becomeAVendor(parameters: .init(userId: uuid, shortBio: "shortBio", webSiteUrl: "https://google.com", geoLocation: "Napoli"))
            
            dismiss(shouldReloadUserData: response )
        }
    }
    
}
