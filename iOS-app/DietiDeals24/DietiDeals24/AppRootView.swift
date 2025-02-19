//
//  AppRootView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/14/25.
//

import SwiftUI

struct AppRootView: View {
    
    let appContainer: AppContainer
    @State var appState: AppState
    @MainActor @State var hasTriedToAuthenticate: Bool = false
    let authCoordinator: AuthFlowCoordinator
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.appState = appContainer.unsafeResolve(AppState.self)
        self.authCoordinator = appContainer.unsafeResolve(AuthFlowCoordinator.self)
    }
    
    var body: some View {
        Group{
            if hasTriedToAuthenticate {
                if appState.authBinding.wrappedValue {
                    ContentView(appState: appState)
                } else {
                    authCoordinator.rootView()
                }
            } else {
                LaunchScreenView()
            }
        }
        .animation(.easeInOut, value: self.hasTriedToAuthenticate)
        .animation(.easeInOut, value: appState.authBinding.wrappedValue)
        .task {
            try? await Task.sleep(for: .seconds(3))
            try? await self.appState.trySilentSignIn()
            self.hasTriedToAuthenticate = true
        }
    }
}

@Observable
class AppState {
    var isAuthenticated: Bool = false
    var authBinding: Binding<Bool> { .init(get: { self.isAuthenticated }, set: { self.isAuthenticated = $0 }) }
    
    private var credentialService: CredentialService
    private var authService: AuthService
    
    init(credentialService: CredentialService, authService: AuthService) {
        self.credentialService = credentialService
        self.authService = authService
    }
    
    public func trySilentSignIn() async throws {
        guard let rfToken = self.credentialService.getRefreshToken() else {
            Logger.log("Refresh token missing", tag: .appState)
            throw AuthServiceError.RefreshTokenMissing
        }
        do {
            let sessionToken = try await self.authService.refreshAccessToken(refreshToken: rfToken)
            self.credentialService.store(credentials: TokenCredentials(accessToken: sessionToken.accessToken, idToken: sessionToken.idToken, refreshToken: sessionToken.refreshToken))
            self.isAuthenticated = true
        } catch {
            self.isAuthenticated = false
            throw error
        }
    }
    
    public func SignInInteractively(email: String, password: String) async throws {
        let sessionToken = try await self.authService.signIn(username: email, password: password)
        self.credentialService.store(credentials: TokenCredentials(accessToken: sessionToken.accessToken, idToken: sessionToken.idToken, refreshToken: sessionToken.refreshToken))
        self.isAuthenticated = true
    }
    
    public func revokeCredentials() {
        self.credentialService.clearCredentials()
        self.isAuthenticated = false
    }
}

public extension Logger.Tag {
    static var appState: Self { "AppState" }
}
