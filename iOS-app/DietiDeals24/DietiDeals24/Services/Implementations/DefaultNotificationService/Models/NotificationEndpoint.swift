//
//  NotificationEndpoint.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/12/25.
//

import Foundation


enum NotificationEndpoint {
    case notifications(page: Int, pageSize: Int, userId: UUID)
    case register(deviceToken: String, userId: UUID)
    case unregister(deviceToken: String)
}

extension NotificationEndpoint {
    var endpoint: EndpointConvertible {
        switch self {
            case .notifications(page: let page, pageSize: let pageSize, userId: let userId):
                return Self.getNotificationEndpoint(page: page, pageSize: pageSize, userId: userId)
            case .register(deviceToken: let deviceToken, userId: let userId):
                return Self.registerDeviceTokenEndpoint(deviceToken: deviceToken, userId: userId)
            case .unregister(deviceToken: let deviceToken):
                return Self.unregisterDeviceTokenEndpoint(deviceToken: deviceToken)
        }
    }
    
    static private func getNotificationEndpoint(page: Int, pageSize: Int, userId: UUID) -> CodableEndpoint<PaginatedResult<NotificationDTO>>{
        
        let baseURL = NetworkConfiguration.backendBaseUrl
        let body = NotificationsRequestBody(userId: userId, page: page, pageNumber: pageSize).jsonObject
        return CodableEndpoint<PaginatedResult<NotificationDTO>>(
            Endpoint(
                baseURL: URL(string: baseURL)!,
                path: "/Notification/get-notifications",
                parameters: body ?? [:],
                encoding: Endpoint.Encoding.json,
                method: .post)
            
        )
    }
    
    static private func registerDeviceTokenEndpoint(deviceToken: String, userId: UUID) -> Endpoint {
        let baseURL = NetworkConfiguration.backendBaseUrl
        let body = RegisterTokenBody(userId: userId, deviceToken: deviceToken).jsonObject
        return
            Endpoint(
                baseURL: URL(string: baseURL)!,
                path: "/Notification/add-notification-token",
                parameters: body ?? [:],
                encoding: Endpoint.Encoding.json,
                method: .post)
    }
    
    static private func unregisterDeviceTokenEndpoint(deviceToken: String) -> Endpoint {
        let baseURL = NetworkConfiguration.backendBaseUrl
        let body = RegisterTokenBody(userId: nil, deviceToken: deviceToken).jsonObject
        return
            Endpoint(
                baseURL: URL(string: baseURL)!,
                path: "/Notification/remove-notification-token",
                parameters: body ?? [:],
                encoding: Endpoint.Encoding.json,
                method: .post)
    }
}
