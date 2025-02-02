//
//  AuthService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

struct AuthServiceResponse<T>: Codable where T: Codable {
    let authResponse: T
}

protocol AuthService: AnyObject {
    func loginAsync<T>(username: String, password: String) async throws -> AuthServiceResponse<T>
}

protocol CredentialService {
    func getAccessTokenAsync() async throws -> String
    func getRefreshTokenAsync() async throws -> String
    func setAccessTokenAsync(_ accessToken: String) async throws -> Void
    func setRefreshTokenAsync(_ refreshToken: String) async throws -> Void
}
