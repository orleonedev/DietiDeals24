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
    
    func loginAsync<T>(username: String, password: String) async throws -> AuthServiceResponse<T> {
        let response: T = try await rest.getCodable(at: CognitoEndpoint.login(username: username, password: password).endpoint)
        return AuthServiceResponse(authResponse: response)
    }
    
    
    
}


class useCase {
    
    let authService: AuthService
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login() async throws {
        let response : AuthServiceResponse<AuthResult> = try await authService.loginAsync(username: "", password: "")
        let result : AuthResult = response.authResponse
    }
}
