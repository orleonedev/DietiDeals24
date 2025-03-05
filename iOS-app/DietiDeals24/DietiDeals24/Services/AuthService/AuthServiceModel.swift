//
//  AuthServiceModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/3/25.
//

import Foundation

protocol AuthTokenSessionGenerator {
    func generateSessionToken() -> AuthTokenSession
}

protocol AuthServiceResponse<AuthResultType> : Codable {
    associatedtype AuthResultType : AuthTokenSessionGenerator
    var authResult: AuthResultType { get }
}

protocol AuthServiceSignUpResponse {
    
}

struct AuthTokenSession: Codable, AuthTokenSessionGenerator {
    
    let accessToken: String?
    let idToken: String?
    let refreshToken: String?
    
    func generateSessionToken() -> AuthTokenSession {
        return self
    }
}

/// Enumerates supported federated login providers.
enum AuthFederatedProvider: String {
    case google
    case facebook
    case apple
    // Extend with additional providers as needed.
}

enum AuthServiceError: LocalizedError {
    case RefreshTokenMissing
    case RefreshTokenExpired
    case SessionCredentialsMissing
    case UnknownError(String)
    
    var errorDescription: String? {
        switch self {
            case .RefreshTokenMissing:
                return "Refresh token is missing."
            case .RefreshTokenExpired:
                return "Refresh token is expired."
            case .UnknownError(let message):
                return message
            case .SessionCredentialsMissing:
                return "Session token is missing"
        }
    }
    
    var notificationName: String {
        String(describing: self)
    }
    
}

struct UserSignUpAttributes {
    let username: String
    let email: String
    let password: String
    let preferredUsername: String
    let name: String
    let birthdate: Date
}

struct ConfirmSignUpModel {
    
}
