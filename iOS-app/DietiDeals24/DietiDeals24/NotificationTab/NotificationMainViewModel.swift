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
    
    let notificationService: NotificationService
    let auctionService: AuctionService
    let coordinator: NotificationCoordinator
    
    init(coordinator: NotificationCoordinator, notificationService: NotificationService, auctionService: AuctionService) {
        self.notificationService = notificationService
        self.coordinator = coordinator
        self.auctionService = auctionService
    }
    
    
    func getNotifications() async {
        
    }
    
    
}
