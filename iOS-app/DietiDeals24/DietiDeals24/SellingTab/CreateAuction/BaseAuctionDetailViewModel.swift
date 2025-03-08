//
//  BaseAuctionDetailViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI
import PhotosUI

enum AuctionImagePreviewState: Hashable {
    case loading(Progress)
    case success(AuctionImage)
    case failure
}

@Observable
class BaseAuctionDetailViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var sellingCoordinator: SellingCoordinator
    
    var imagesPickerSelection: [PhotosPickerItem] = [] {
        didSet {
            print("SETTING NEW IMAGES")
            self.imagesPreviewState.removeAll()
            self.imagesPickerSelection.indices.forEach { index in
                let progress = loadTransferable(from: self.imagesPickerSelection[index], at: index)
                self.imagesPreviewState.append(.loading(progress))
            }
        }
    }
    
    var imagesPreviewState: [AuctionImagePreviewState] = []
    
    var baseAuction: CreateBaseAuctionModel = .init(title: "", description: "", category: nil, imagesPreview: [])
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
        self.sellingCoordinator.dismiss()
    }
    
    @MainActor
    func goToAuctionDetails() {
        validateTitle()
        validateDescription()
        validateCategory()
        guard !validationTitleError && !validationDescriptionError && !validationCategoryError else { return }
        self.baseAuction.imagesPreview = self.imagesPreviewState
        self.sellingCoordinator.goToDetailAuction(baseAuction: self.baseAuction)
    }
    
    private func loadTransferable(from selectedImage: PhotosPickerItem, at index: Int) -> Progress {
        return selectedImage.loadTransferable(type: AuctionImage.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let auctionImage?):
                        self.imagesPreviewState[index] = .success(auctionImage)
                case .success(nil):
                        self.imagesPreviewState[index] = .failure
                case .failure(_):
                    self.imagesPreviewState[index] = .failure
                }
            }
        }
    }
}
