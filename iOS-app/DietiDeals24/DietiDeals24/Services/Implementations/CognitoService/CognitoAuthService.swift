//
//  CognitoAuthService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

final class CognitoAuthService: AuthService {
    
    let rest: RESTDataSource
    init(rest: RESTDataSource) {
        self.rest = rest
    }
    
    func signIn(username: String, password: String) async throws -> AuthTokenSession {
        let response: CognitoAuthResponse = try await rest.getCodable(
            at: CognitoEndpoint.login(
                method: .usernamePassword(
                    username: username,
                    password: password
                )
            ).endpoint
        )
        let result: AuthTokenSession = response.authResult
        return result
    }
    
    func signIn(withProvider provider: AuthFederatedProvider, thirdPartyToken: String) async throws -> AuthTokenSession {
        let response: CognitoAuthResponse = try await rest.getCodable(
            at: CognitoEndpoint.login(
                method: .provider(provider: provider.rawValue, token: thirdPartyToken)
            ).endpoint
        )
        let result: AuthTokenSession = response.authResult
        return result
    }
    
    func refreshAccessToken(refreshToken: String) async throws -> AuthTokenSession {
        let response: CognitoAuthResponse = try await rest.getCodable(
            at: CognitoEndpoint.login(
                method: .refreshToken(refreshToken: refreshToken)
            ).endpoint
        )
        let result: AuthTokenSession = response.authResult
        return result
    }
    
    func signOut() async throws {
        
    }
    
}
