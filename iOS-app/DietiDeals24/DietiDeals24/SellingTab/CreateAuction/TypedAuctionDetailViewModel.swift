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
    var threshold: String = ""
    var timer: String = ""
    var secretPrice: String = ""
    
    var startingPriceValidationError: Bool = false
    var timerValidationError: Bool = false
    var thresholdValidationError: Bool = false
    var secretPriceValidationError: Bool = false
    
    init( sellingCoordinator: SellingCoordinator) {
        self.sellingCoordinator = sellingCoordinator
    }
    
    public func setBaseAuction(_ baseAuction: CreateBaseAuctionModel) {
        self.baseAuction = baseAuction
    }
    
    func validateStartingPrice()  {
        startingPriceValidationError = startingPrice.isEmpty
    }
    
    func validateTimer()  {
        timerValidationError = timer.isEmpty || Int(timer) ?? 0 < 1
    }
    
    func validateThreshold()  {
        thresholdValidationError = timer.isEmpty || Int(timer) ?? 0 < 1
    }
    
    func validateSecretPrice()  {
        secretPriceValidationError = auctionType == .descending ? secretPrice.isEmpty || Double(secretPrice) ?? 0.0 > Double(startingPrice) ?? -1.0 : false
    }
    
    @discardableResult
    func validateAll() -> Bool {
        validateStartingPrice()
        validateTimer()
        validateThreshold()
        if auctionType == .descending {
            validateSecretPrice()
        }
        return !startingPriceValidationError && !timerValidationError && !thresholdValidationError && !secretPriceValidationError
    }
    
    @MainActor
    func goToAuctionPreview() {
        validateAll()
        guard let base = self.baseAuction, let startPrice = Double(self.startingPrice), let thresh = Double(self.threshold), let time = Int(timer) else { return }
        let auction = CreateAuctionModel(baseDetail: base, auctionType: self.auctionType, startingPrice: startPrice, threshold: thresh, timer: time, secretPrice: Double(self.secretPrice))
        self.sellingCoordinator.goToAuctionPreview(auction: auction)
    }
    
    @MainActor
    func tryToDismiss() {
        self.sellingCoordinator.dismiss(to: .toRoot)
    }
}
