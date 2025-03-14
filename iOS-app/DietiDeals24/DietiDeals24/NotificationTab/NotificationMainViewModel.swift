//
//  NotificationMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

import SwiftUI

@Observable
class NotificationMainViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var notificationCount: Int = 0
    var page: Int = 1
    var pageSize: Int = 20
    var isFetchingNotifications: Bool = false
    var shouldFetchMoreNotifications: Bool = true
    var notifications: [NotificationModel] = []
    
    let notificationService: NotificationService
    let auctionService: AuctionService
    let coordinator: NotificationCoordinator
    
    init(coordinator: NotificationCoordinator, notificationService: NotificationService, auctionService: AuctionService) {
        self.notificationService = notificationService
        self.coordinator = coordinator
        self.auctionService = auctionService
    }
    
    @MainActor
    func getNotifications() {
        Task {
            guard let userId = await UUID(uuidString: coordinator.getUserData()?.userID ?? "") else { return }
            guard shouldFetchMoreNotifications, !isFetchingNotifications else { return }
            isFetchingNotifications = true
            isLoading = true
            defer {
                self.isFetchingNotifications = false
                self.isLoading = false
            }
            do {
                let response: PaginatedResult<NotificationDTO> = try await notificationService.getNotifications(page: self.page, pageSize: self.pageSize, userId: userId)
                let newNotifications: [NotificationModel] = response.results.compactMap { NotificationModel(from: $0)}
                self.notificationCount = response.totalRecords
                self.page = response.pageNumber
                self.notifications.append(contentsOf: newNotifications)
                self.shouldFetchMoreNotifications = notificationCount > notifications.count
                
            } catch {
                print("something went wrong")
            }
        }
    }
    
    @MainActor
    func getAuctionDetail(_ auctionID: UUID) {
        Task {
            print(auctionID)
            self.isLoading = true
            
            let auctionDTO = try await auctionService.fetchAuctionDetails(by: auctionID)
            let model = try AuctionDetailModel(from: auctionDTO)
            
            self.isLoading = false
            self.coordinator.goToAuction(model)
            
        }
    }
    
}
