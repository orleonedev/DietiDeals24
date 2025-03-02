//
//  BaseAuctionDetailViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

@Observable
class BaseAuctionDetailViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var sellingCoordinator: SellingCoordinator
    
    var baseAuction: CreateBaseAuctionModel = .init(title: "", description: "", category: nil)
    var validationTitleError: Bool = false
    var validationDescriptionError: Bool = false
    var validationCategoryError: Bool = false
    
    
    init(sellingCoordinator: SellingCoordinator) {
        self.sellingCoordinator = sellingCoordinator
    }
    
    func validateTitle() {
        validationTitleError = self.baseAuction.title.isEmpty
    }
    
    func validateDescription() {
        validationDescriptionError = self.baseAuction.description.isEmpty
    }
    
    func validateCategory() {
        validationCategoryError = (self.baseAuction.category == nil || self.baseAuction.category == .all)
    }
    
    @MainActor
    func tryToDismiss() {
        self.sellingCoordinator.dismiss(to: .toRoot)
    }
    
    @MainActor
    func goToAuctionDetails() {
        validateTitle()
        validateDescription()
        validateCategory()
        guard !validationTitleError && !validationDescriptionError && !validationCategoryError else { return }
        self.sellingCoordinator.goToDetailAuction(baseAuction: self.baseAuction)
    }
    
    
}
