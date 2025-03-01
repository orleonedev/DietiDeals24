//
//  SellingMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

@Observable
class SellingMainViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var sellingCoordinator: SellingCoordinator
    
    var isSeller: Bool = false
    
    init(sellingCoordinator: SellingCoordinator) {
        self.sellingCoordinator = sellingCoordinator
    }
    
    func checkSellerStatus() async {
        let userData = await self.sellingCoordinator.getUserData()
        isSeller = userData?.role == .seller
    }
    
    @MainActor
    func becomeASeller() {
        self.sellingCoordinator.becomeAVendor(onDismiss: {Task{ await self.checkSellerStatus()}})
    }
    
    @MainActor
    func createAuction() {
        self.sellingCoordinator.goToBaseAuction()
    }
}
