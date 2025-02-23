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
