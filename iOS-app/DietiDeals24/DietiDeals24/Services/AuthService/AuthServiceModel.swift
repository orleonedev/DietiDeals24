//
//  AuthServiceModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/3/25.
//

protocol AuthServiceResponse<AuthResultType> : Codable {
    associatedtype AuthResultType
    var authResult: AuthResultType { get }
}

struct AuthTokenSession: Codable {
    let accessToken: String?
    let idToken: String?
    let refreshToken: String?
}

/// Enumerates supported federated login providers.
enum AuthFederatedProvider: String {
    case google
    case facebook
    // Extend with additional providers as needed.
}
