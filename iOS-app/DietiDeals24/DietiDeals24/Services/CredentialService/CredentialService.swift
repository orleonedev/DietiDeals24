//
//  CredentialService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 05/02/25.
//


protocol CredentialService: AnyObject {
    
    func store(credentials: TokenCredentials)
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func getIdToken() -> String?
    func clearCredentials()
    
}

extension Logger.Tag {
    static var credentialService: Self { "CredentialService" }
}
