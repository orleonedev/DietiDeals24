//
//  AppContainer.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/15/25.
//
import SwiftUI

@Observable
class AppContainer: DependencyContainer {
    private(set) var container: ObjectContainer = ObjectContainer()
    
    init() {
        self.container = ObjectContainer()
        self.setupServices()
        self.setupRouting()
    }
}


extension AppContainer {
    
    func setupServices() {
#if DEV || DEBUG
        Logger.shared.add(logger: ConsoleLogger(logLevel: .verbose))
        #else
        Logger.shared.add(logger: ConsoleLogger(logLevel: .error))
#endif
        register(for: RESTDataSource.self, scope: .singleton) {
            DefaultRESTDataSource()
        }
        register(for: AuthService.self, scope: .singleton) { [self] in
            CognitoAuthService(rest: unsafeResolve())
        }
        register(for: CredentialService.self, scope: .singleton) {
            KeychainCredentialService()
        }
        
        register(for: AppState.self, scope: .singleton) {
            AppState(credentialService: self.unsafeResolve(), authService: self.unsafeResolve())
        }
        
    }
    
}

extension AppContainer {
    func setupRouting() {
        
        self.registerAuthFlow()

        
    }
    
    private func registerAuthFlow() {
        register(for: AuthFlowCoordinator.AuthRouter.self, scope: .singleton) { @MainActor [self] in
            AuthFlowCoordinator.AuthRouter()
        }
        register(for: AuthFlowCoordinator.self, scope: .singleton) {
            AuthFlowCoordinator(container: self)
        }
        register(for: SignInViewModel.self) { [self] in
            SignInViewModel(coordinator: unsafeResolve())
        }
        register(for: SignUpViewModel.self) { [self] in
            SignUpViewModel(coordinator: unsafeResolve())
        }
        register(for: CodeVerificationViewModel.self) { [self] in
            CodeVerificationViewModel(coordinator: unsafeResolve())
        }
    }
    
}
