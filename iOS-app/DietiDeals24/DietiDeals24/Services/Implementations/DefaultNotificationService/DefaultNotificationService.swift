//
//  DefaultNotificationService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

import Foundation


class DefaultNotificationService: NotificationService {
    
    let rest: RESTDataSource
    
    @UserDefault("deviceToken", defaultValue: nil)
    var deviceToken: String?
    
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func getNotifications(page: Int, pageSize: Int, userId: UUID) async throws -> PaginatedResult<NotificationDTO> {
        let paginated: PaginatedResult<NotificationDTO>  = try await rest.getCodable(at: NotificationEndpoint.notifications(page: page, pageSize: pageSize, userId: userId).endpoint)
        return paginated
    }
    
    func registerForRemoteNotifications(with deviceToken: String, forUser userId: UUID) async throws {
        let _ = try await rest.getData(at: NotificationEndpoint.register(deviceToken: deviceToken, userId: userId).endpoint)
        self.deviceToken = deviceToken
    }
    
    func unregisterForRemoteNotifications() async throws {
        guard let deviceToken else { return }
        let _ = try await rest.getData(at: NotificationEndpoint.unregister(deviceToken: deviceToken).endpoint)
    }
    
}
