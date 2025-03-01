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
        self.registerUserArea()
        self.registerSellingTab()
        self.registerExploreTab()
        self.registerSearchTab()
        self.registerNotificationTab()
        self.registerMainTab()

    }
    
    //MARK: - AUTH
    private func registerAuthFlow() {
        register(for: AuthFlowCoordinator.AuthRouter.self) { @MainActor [self] in
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
    
    //MARK: - MAIN
    private func registerMainTab() {
        
        register(for: MainTabCoordinator.self, scope: .singleton) {
            MainTabCoordinator(appContainer: self)
        }
        
        register(for: MainTabCoordinator.TabRouter.self) { @MainActor [self] in
            MainTabCoordinator.TabRouter()
        }
        
        register(for: MainTabViewModel.self) { [self] in
            MainTabViewModel(mainCoordinator: self.unsafeResolve())
        }
        
        
    }
    
    //MARK: - USER AREA TAB
    private func registerUserArea() {
        register(for: UserAreaCoordinator.self, scope: .singleton) {
            UserAreaCoordinator(appContainer: self)
        }
        
        register(for: UserAreaCoordinator.UserAreaRouter.self) { @MainActor [self] in
            UserAreaCoordinator.UserAreaRouter()
        }
        
        register(for: UserAreaMainViewModel.self) {
            UserAreaMainViewModel(coordinator: self.unsafeResolve())
        }
    }
    
    //MARK: - SELL TAB
    private func registerSellingTab() {
        register(for: SellingCoordinator.self, scope: .singleton) {
            SellingCoordinator(appContainer: self)
        }
        
        register(for: SellingCoordinator.SellingRouter.self) { @MainActor [self] in
            SellingCoordinator.SellingRouter()
        }
        
        register(for: BecomeAVendorViewModel.self) {
            BecomeAVendorViewModel(sellingCoordinator: self.unsafeResolve())
        }
        register(for: SellingMainViewModel.self) {
            SellingMainViewModel(sellingCoordinator: self.unsafeResolve())
        }
        
    }
    
    //MARK: - EXPLORE TAB
    private func registerExploreTab() {
        register(for: ExploreCoordinator.self, scope: .singleton) {
            ExploreCoordinator(appContainer: self)
        }
        
        register(for: ExploreCoordinator.ExploreRouter.self) { @MainActor [self] in
            ExploreCoordinator.ExploreRouter()
        }
        
        register(for: ExploreMainViewModel.self) {
            ExploreMainViewModel(coordinator: self.unsafeResolve())
        }
    }
    
    //MARK: - SEARCH TAB
    private func registerSearchTab() {
        register(for: SearchCoordinator.self, scope: .singleton) {
            SearchCoordinator(appContainer: self)
        }
        
        register(for: SearchCoordinator.SearchRouter.self) { @MainActor [self] in
            SearchCoordinator.SearchRouter()
        }
        
        register(for: SearchMainViewModel.self) {
            SearchMainViewModel(coordinator: self.unsafeResolve())
        }
        
    }
    
    //MARK: - NOTIFICATIONS TAB
    private func registerNotificationTab() {
        register(for: NotificationCoordinator.self, scope: .singleton) {
            NotificationCoordinator(appContainer: self)
        }
        
        register(for: NotificationCoordinator.NotificationRouter.self) { @MainActor [self] in
            NotificationCoordinator.NotificationRouter()
        }
    }
}
