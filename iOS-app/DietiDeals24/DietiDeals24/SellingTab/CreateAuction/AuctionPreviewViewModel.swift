//
//  AuctionPreviewViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

@Observable
class AuctionPreviewViewModel: LoadableViewModel {
    var isLoading: Bool = false
    
    var sellingCoordinator: SellingCoordinator
    var auction: CreateAuctionModel?
    init(sellingCoordinator: SellingCoordinator) {
        self.sellingCoordinator = sellingCoordinator
    }
    
    public func setAuction(_ auction: CreateAuctionModel) {
        self.auction = auction
    }
    
    @MainActor
    func tryToDismiss() {
        self.sellingCoordinator.dismiss(to: .toRoot)
    }
    
    @MainActor
    func publishAuction() {
        guard let auction = self.auction else { return }
        self.isLoading = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            self.isLoading = false
            
            //if successful show alert and dismiss
            self.sellingCoordinator.dismiss(to: .toRoot)
        }
    }
    
}
