//
//  TypedAuctionDetailViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//
import SwiftUI

@Observable
class TypedAuctionDetailViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var sellingCoordinator: SellingCoordinator
    var baseAuction: CreateBaseAuctionModel?
    
    var auctionType: AuctionType = .incremental
    var startingPrice: String = ""
    var threshold: Double = 1.0
    var timer: Int = 1
    var secretPrice: String = ""
    
    init( sellingCoordinator: SellingCoordinator) {
        self.sellingCoordinator = sellingCoordinator
    }
    
    public func setBaseAuction(_ baseAuction: CreateBaseAuctionModel) {
        self.baseAuction = baseAuction
    }
    
    
}
