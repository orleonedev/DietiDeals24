//
//  AuthService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

/// The AuthService protocol defines the authentication actions using async/await.
protocol AuthService {
    /// Signs in using username and password credentials.
    ///
    /// - Parameters:
    ///   - username: The user's username.
    ///   - password: The user's password.
    /// - Returns: An AuthSession containing tokens upon successful login.
    func signIn(username: String, password: String) async throws -> AuthTokenSession

    /// Signs in using a federated provider.
    ///
    /// - Parameters:
    ///   - provider: The federated provider (e.g., Google, Facebook).
    ///   - thirdPartyToken: The token obtained from the provider’s SDK.
    /// - Returns: An AuthSession containing tokens upon successful login.
    func signIn(withProvider provider: AuthFederatedProvider, thirdPartyToken: String) async throws -> AuthTokenSession

    /// Refreshes the access token using a stored refresh token.
    ///
    /// This method can be invoked by the network layer when the access token expires.
    /// - Returns: A new AuthSession with updated tokens.
    func refreshAccessToken(refreshToken: String) async throws -> AuthTokenSession

    /// Signs out the current user, clearing any stored credentials.
    func signOut() async throws
}


