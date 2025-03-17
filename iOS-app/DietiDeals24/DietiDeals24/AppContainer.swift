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
        typealias AuthRestDataSource = DefaultRESTDataSource
        
        register(for: AuthRestDataSource.self,scope: .singleton) {
            DefaultRESTDataSource()
        }
        
        register(for: AuthService.self, scope: .singleton) { [self] in
            CognitoAuthService(rest: unsafeResolve(AuthRestDataSource.self))
        }
        register(for: CredentialService.self, scope: .singleton) {
            KeychainCredentialService()
        }
        
        register(for: RESTDataSource.self) {
            DefaultRESTDataSource(credentialService: self.unsafeResolve(CredentialService.self), authService: self.unsafeResolve(AuthService.self))
        }
        
        register(for: AuctionService.self) {
            DefaultAuctionService(rest: self.unsafeResolve())
        }
        
        register(for: VendorService.self) {
            DefaultVendorService(rest: self.unsafeResolve())
        }
        
        register(for: BidService.self) {
            DefaultBidService(rest: self.unsafeResolve())
        }
        
        register(for: NotificationService.self) {
            DefaultNotificationService(rest: self.unsafeResolve())
        }
        
        register(for: AppState.self, scope: .singleton) {
            AppState(credentialService: self.unsafeResolve(), authService: self.unsafeResolve(), notificationService: self.unsafeResolve())
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
            SignInViewModel(coordinator: unsafeResolve(), validator: Validator())
        }
        register(for: SignUpViewModel.self) { [self] in
            SignUpViewModel(coordinator: unsafeResolve(), validator: Validator())
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
            UserAreaMainViewModel(coordinator: self.unsafeResolve(), vendorService: self.unsafeResolve(), auctionService: self.unsafeResolve())
        }
        
        register(for: AuctionDetailMainViewModel.self, tag: .init("UserArea")) {
            AuctionDetailMainViewModel(auctionCoordinator: self.unsafeResolve(UserAreaCoordinator.self), vendorService: self.unsafeResolve(VendorService.self), auctionService: self.unsafeResolve(AuctionService.self))
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
            BecomeAVendorViewModel(sellingCoordinator: self.unsafeResolve(), vendorService: self.unsafeResolve())
        }
        register(for: SellingMainViewModel.self) {
            SellingMainViewModel(sellingCoordinator: self.unsafeResolve())
        }
        
        register(for: BaseAuctionDetailViewModel.self) {
            BaseAuctionDetailViewModel(sellingCoordinator: self.unsafeResolve())
        }
        
        register(for: TypedAuctionDetailViewModel.self) {
            TypedAuctionDetailViewModel(sellingCoordinator: self.unsafeResolve())
        }
        
        register(for: AuctionPreviewViewModel.self) {
            AuctionPreviewViewModel(sellingCoordinator: self.unsafeResolve(), auctionService: self.unsafeResolve())
        }
        
        register(for: SellingCoordinator.SellingAuctionVM.self, tag: .init("Selling")) {
            AuctionDetailMainViewModel(auctionCoordinator: self.unsafeResolve(SellingCoordinator.self), vendorService: self.unsafeResolve(VendorService.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: UserProfileViewModel.self, tag: .init("Selling")) {
            UserProfileViewModel(coordinator: self.unsafeResolve(SellingCoordinator.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: PresentOfferViewModel.self, tag: .init("Selling")) {
            PresentOfferViewModel(auctionCoordinator: self.unsafeResolve(SellingCoordinator.self), bidService: self.unsafeResolve(BidService.self))
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
            ExploreMainViewModel(coordinator: self.unsafeResolve(), auctionService: self.unsafeResolve())
        }
        
        register(for: ExploreCoordinator.ExploreAuctionVM.self, tag: .init("Explore")) {
            AuctionDetailMainViewModel(auctionCoordinator: self.unsafeResolve(ExploreCoordinator.self), vendorService: self.unsafeResolve(VendorService.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: UserProfileViewModel.self, tag: .init("Explore")) {
            UserProfileViewModel(coordinator: self.unsafeResolve(ExploreCoordinator.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: PresentOfferViewModel.self, tag: .init("Explore")) {
            PresentOfferViewModel(auctionCoordinator: self.unsafeResolve(ExploreCoordinator.self), bidService: self.unsafeResolve(BidService.self))
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
            SearchMainViewModel(coordinator: self.unsafeResolve(), auctionService: self.unsafeResolve())
        }
        register(for: SearchCoordinator.SearchAuctionVM.self, tag: .init("Search")) {
            AuctionDetailMainViewModel(auctionCoordinator: self.unsafeResolve(SearchCoordinator.self), vendorService: self.unsafeResolve(VendorService.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: UserProfileViewModel.self, tag: .init("Search")) {
            UserProfileViewModel(coordinator: self.unsafeResolve(SearchCoordinator.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: PresentOfferViewModel.self, tag: .init("Search")) {
            PresentOfferViewModel(auctionCoordinator: self.unsafeResolve(SearchCoordinator.self), bidService: self.unsafeResolve(BidService.self))
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
        
        register(for: NotificationMainViewModel.self) {
            NotificationMainViewModel(coordinator: self.unsafeResolve(), notificationService: self.unsafeResolve(), auctionService: self.unsafeResolve())
        }
        
        register(for: AuctionDetailMainViewModel.self, tag: .init("Notification")) {
            AuctionDetailMainViewModel(auctionCoordinator: self.unsafeResolve(NotificationCoordinator.self), vendorService: self.unsafeResolve(VendorService.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
        register(for: UserProfileViewModel.self, tag: .init("Notification")) {
            UserProfileViewModel(coordinator: self.unsafeResolve(NotificationCoordinator.self), auctionService: self.unsafeResolve(AuctionService.self))
        }
        
    }
}
