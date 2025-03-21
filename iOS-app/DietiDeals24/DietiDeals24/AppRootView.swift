//
//  AppRootView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/14/25.
//

import SwiftUI

struct AppRootView: View, LoadableView {
    
    let appContainer: AppContainer
    @State var viewModel: AppState
    @MainActor @State var hasTriedToAuthenticate: Bool = false
    let authCoordinator: AuthFlowCoordinator
    let mainTabCoordinator: MainTabCoordinator
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
        self.viewModel = appContainer.unsafeResolve(AppState.self)
        self.authCoordinator = appContainer.unsafeResolve(AuthFlowCoordinator.self)
        self.mainTabCoordinator = appContainer.unsafeResolve(MainTabCoordinator.self)
    }
    
    var body: some View {
        Group{
            if hasTriedToAuthenticate {
                if viewModel.isAuthenticated {
                    mainTabCoordinator.rootView()
                } else {
                    authCoordinator.rootView()
                }
            } else {
                LaunchScreenView()
            }
        }
        .overlay {
            self.loaderView()
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .animation(.easeInOut, value: self.hasTriedToAuthenticate)
        .animation(.easeInOut, value: viewModel.isAuthenticated)
        .task {
            try? await Task.sleep(for: .seconds(3))
            try? await self.viewModel.trySilentSignIn()
            self.hasTriedToAuthenticate = true
        }
    }
}

@Observable
class AppState: LoadableViewModel {
    var isLoading: Bool = false
    var isAuthenticated: Bool = false
    
    private var credentialService: CredentialService
    private var authService: AuthService
    private var notificationService: NotificationService
    
    init(credentialService: CredentialService, authService: AuthService, notificationService: NotificationService) {
        self.notificationService = notificationService
        self.credentialService = credentialService
        self.authService = authService
        NotificationCenter.default.addObserver(forName: .init(AuthServiceError.RefreshTokenExpired.notificationName), object: self, queue: .main) { _ in
            self.revokeCredentials()
        }
    }
    
    public func trySilentSignIn() async throws {
        isLoading = true
        guard let rfToken = self.credentialService.getRefreshToken() else {
            Logger.log("Refresh token missing", tag: .appState)
            isLoading = false
            self.isAuthenticated = false
            throw AuthServiceError.RefreshTokenMissing
        }
        do {
            let sessionToken = try await self.authService.refreshAccessToken(refreshToken: rfToken)
            self.credentialService.storeToken(credentials: TokenCredentials(accessToken: sessionToken.accessToken, idToken: sessionToken.idToken, refreshToken: sessionToken.refreshToken))
            self.isAuthenticated = true
            await self.registerForRemoteNotifications()
            isLoading = false
        } catch {
            isLoading = false
            self.isAuthenticated = false
            throw error
        }
    }
    
    public func SignInInteractively(email: String, password: String) async throws {
        let sessionToken = try await self.authService.signIn(username: email, password: password)
        self.credentialService.storeToken(credentials: TokenCredentials(accessToken: sessionToken.accessToken, idToken: sessionToken.idToken, refreshToken: sessionToken.refreshToken))
        self.isAuthenticated = true
        await self.registerForRemoteNotifications()
    }
    
    public func SignInWithProvider(_ provider: AuthFederatedProvider, token: String) async throws {
        let sessionToken = try await self.authService.signIn(withProvider: provider, thirdPartyToken: token)
        self.credentialService.storeToken(credentials: TokenCredentials(accessToken: sessionToken.accessToken, idToken: sessionToken.idToken, refreshToken: sessionToken.refreshToken))
        self.isAuthenticated = true
        await self.registerForRemoteNotifications()
        
    }
    
    public func signUp(model: UserSignUpAttributes) async throws -> CognitoSignUpResponse {
        guard let response = try await self.authService.signUp(model: model) as? CognitoSignUpResponse else {throw AuthServiceError.UnknownError("SignUp Failed")}
        self.credentialService.setSessionCredentials(session: .init(session: response.session, username: model.username))
        return response
    }
    
    public func confirmSignUp(code: String) async throws -> Bool {
        guard let sessionCred = self.credentialService.getSessionCredentials(),
              let username = sessionCred.username,
              !username.isEmpty else {
            Logger.log("Session credent missing", tag: .credentialService)
            throw AuthServiceError.SessionCredentialsMissing
        }
        
        let response = try await self.authService.confirmSignUp(session: sessionCred, code: code)
        self.credentialService.setSessionCredentials(session: response)
        return true
        
    }
    
    //FIXME: Session Auth doesn't work, cognito problem
//    public func trySessionAuthentication() async throws {
//        guard let sessionCred = self.credentialService.getSessionCredentials(),
//              let session = sessionCred.session, let username = sessionCred.username,
//              !session.isEmpty,
//              !username.isEmpty else {
//            Logger.log("Session credent missing", tag: .credentialService)
//            throw AuthServiceError.SessionCredentialsMissing
//        }
//        do {
//            let response = try await self.authService.signIn(withSessionCredentials: sessionCred)
//            self.credentialService.storeToken(credentials: TokenCredentials(accessToken: response.accessToken, idToken: response.idToken, refreshToken: response.refreshToken))
//            //self.credentialService.clearSessionCredentials()
//            self.isAuthenticated = true
//        }catch {
//            //self.credentialService.clearSessionCredentials()
//            self.isAuthenticated = false
//            throw error
//        }
//    }
    
    public func revokeCredentials() {
        self.credentialService.clearCredentials()
        self.isAuthenticated = false
    }
    
    public func getUserDataModel() async -> UserDataModel? {
        guard let account = self.credentialService.getAccountModel() else {return nil}
        let role = Int(account.customRole ?? "0")
        return UserDataModel(name: account.name ?? "", username: account.preferredUsername ?? "", email: account.email ?? "", role: UserRole(rawValue: role ?? 0) ?? .buyer, userID: account.sub, vendorId: account.vendorId)
    }
    
    public func logOut() async {
        self.revokeCredentials()
        try? await notificationService.unregisterForRemoteNotifications()
        await UIApplication.shared.unregisterForRemoteNotifications()
        try? await self.authService.signOut()
    }
    
    @MainActor
    public func registerForRemoteNotifications() async {
        let center = UNUserNotificationCenter.current()
        do {
            let authorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
            
        } catch {
            print("error registering for remote notifications: \(error)")
        }
    }
}

public extension Logger.Tag {
    static var appState: Self { "AppState" }
}
