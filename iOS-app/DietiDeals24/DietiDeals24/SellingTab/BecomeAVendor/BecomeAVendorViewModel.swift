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
    
    
    init(sellingCoordinator: SellingCoordinator) {
        self.sellingCoordinator = sellingCoordinator
    }
    
    @MainActor
    func dismiss() {
        sellingCoordinator.dismiss()
    }
    
    
}
