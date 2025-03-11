//
//  DefaultNotificationService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

class DefaultNotificationService: NotificationService {
    
    let rest: RESTDataSource
    
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func getNotifications() {
        
    }
    
}
