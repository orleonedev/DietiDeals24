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
        let result: AuthTokenSession = response.authResult.generateSessionToken()
        return result
    }
    
    func signIn(withProvider provider: AuthFederatedProvider, thirdPartyToken: String) async throws -> AuthTokenSession {
        let response: CognitoAuthResponse = try await rest.getCodable(
            at: CognitoEndpoint.login(
                method: .provider(provider: provider, token: thirdPartyToken)
            ).endpoint
        )
        let result: AuthTokenSession = response.authResult.generateSessionToken()
        return result
    }
    
    func refreshAccessToken(refreshToken: String) async throws -> AuthTokenSession {
        let response: CognitoAuthResponse = try await rest.getCodable(
            at: CognitoEndpoint.login(
                method: .refreshToken(refreshToken: refreshToken)
            ).endpoint
        )
        let result: AuthTokenSession = response.authResult.generateSessionToken()
        return result
    }
    
    func signIn(withSessionCredentials sessionCredentials: SessionCredential) async throws -> AuthTokenSession {
        let response: CognitoAuthResponse = try await rest.getCodable(
            at: CognitoEndpoint.login(
                method: .session(credentials: sessionCredentials)
            ).endpoint
        )
        let result: AuthTokenSession = response.authResult.generateSessionToken()
        return result
    }
    
    func signUp(model: UserSignUpAttributes) async throws -> any AuthServiceSignUpResponse {
        let response: CognitoSignUpResponse = try await rest.getCodable(
            at: CognitoEndpoint.signUp(
                model: model
            ).endpoint
        )
        
        return response
    }
    
    func confirmSignUp(session sessionCredential: SessionCredential, code: String) async throws -> SessionCredential {
        let response: CognitoConfirmSignUpResponse = try await rest.getCodable(
            at: CognitoEndpoint.confirmSignUp(username: sessionCredential.username ?? "", code: code).endpoint
        )
        let newSessionCredential: SessionCredential = .init(session: response.session, username: sessionCredential.username)
        return newSessionCredential
    }
    
    func signOut() async throws {
        //TODO: invalidate Tokens
    }
    
}
