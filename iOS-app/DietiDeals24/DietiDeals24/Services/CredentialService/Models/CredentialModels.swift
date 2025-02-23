//
//  CredentialModels.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 05/02/25.
//

struct TokenCredentials {
    let accessToken: String?
    let idToken: String?
    let refreshToken: String?
}

struct SessionCredential {
    let session: String?
    let username: String?
}

struct UserAccount: Codable {
    let sub: String?
    let emailVerified: Bool?
    let birthdate: String?
    let iss: String?
    let cognitoUsername, preferredUsername, originJti, aud: String?
    let eventID, tokenUse: String?
    let authTime: Int?
    let name: String?
    let exp: Int?
    let customRole: String?
    let iat: Int?
    let jti, email: String?

    enum CodingKeys: String, CodingKey {
        case sub
        case emailVerified = "email_verified"
        case birthdate, iss
        case cognitoUsername = "cognito:username"
        case preferredUsername = "preferred_username"
        case originJti = "origin_jti"
        case aud
        case eventID = "event_id"
        case tokenUse = "token_use"
        case authTime = "auth_time"
        case name, exp
        case customRole = "custom:role"
        case iat, jti, email
    }
}



