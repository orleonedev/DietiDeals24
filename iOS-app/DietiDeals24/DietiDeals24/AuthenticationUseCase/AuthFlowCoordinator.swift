//
//  AuthFlowCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 13/02/25.
//

import RoutingKit
import SwiftUI

//typealias AuthDestination = Destination
//
//@Observable
//class AuthenticationFlow {
//    
//    var isAuthenticated: Bool = false
//    var authenticationBinding: Binding<Bool> { .init(get: { self.isAuthenticated }, set: { self.isAuthenticated = $0 }) }
//    @MainActor static let authRouter = SwiftUIRouter()
//    
//    @MainActor var root: some View {
//        RoutableRootView(router: Self.authRouter) {
//            SignInView()
//        }
//        
//    }
//}
//
//extension AuthDestination {
//    static let SignIn = Destination { SignInView() }
//    static let SignUp = Destination { SignUpView() }
//    static let CodeConfirmation = Destination { CodeVerificationView() }
//}

//struct AuthFlow {
//    struct SignInRouteDefinition: EquatableRouteDefinition {
//        
//    }
//}

class AuthFlowCoordinator {
    typealias AuthRouter = RoutingKit.Router
    
    let container: AppContainer
    var router: AuthRouter
    var appState: AppState
    
    init(container: AppContainer) {
        self.container = container
        self.appState = container.unsafeResolve()
        self.router = container.unsafeResolve(AuthRouter.self)
    }
    
    public func SignInInteractively(email: String, password: String) async throws {
        try await appState.SignInInteractively(email: email, password: password)
    }
    
    @MainActor @ViewBuilder
    func rootView() -> some View {
        RoutingKit.RoutableRootView(router: router) {
            SignInView(viewModel: self.container.unsafeResolve())
        }
    }
    
    @MainActor
    public func goToSignUp() {
        self.router.navigate(to: self.signUpDestination(), type: .sheet)
    }
    
    @MainActor
    public func gotoCodeConfirmation() {
        self.router.navigate(to: self.codeConfirmationDestination(), type: .push)
    }
    
    @MainActor
    public func goBack() {
        self.router.dismiss()
    }
    
    private func signUpDestination() -> RoutingKit.Destination {
        .init {
            SignUpView(viewModel: self.container.unsafeResolve())
        }
    }
    
    private func codeConfirmationDestination() -> RoutingKit.Destination {
        .init {
            CodeVerificationView(viewModel: self.container.unsafeResolve())
        }
    }
    
}
