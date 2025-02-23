//
//  AuthFlowCoordinator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 13/02/25.
//

import RoutingKit
import SwiftUI

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
    
    public func signUp(model: UserSignUpAttributes) async throws {
        let response = try await appState.signUp(model: model)
        await self.gotoCodeConfirmation(email: response.codeDeliveryDetails?.destination)
    }
    
    public func sendConfirmationCode(code: String) async throws {
        let _ = try await appState.confirmSignUp(code: code)
        
        //FIXME: AUTO SIGN IN DOES NOT WORK
//        if success {
//            do {
//                try await appState.trySessionAuthentication()
//            } catch {
//                print(error)
//                throw error
//            }
//        }
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
    public func gotoCodeConfirmation(email: String?) {
        self.router.navigate(to: self.codeConfirmationDestination(email: email), type: .push)
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
    
    @MainActor
    private func restart() {
        self.router.dismiss(option: .toRoot)
    }
    
    private func codeConfirmationDestination(email: String?) -> RoutingKit.Destination {
        .init {
            let viewModel = self.container.unsafeResolve(CodeVerificationViewModel.self)
            viewModel.setFromSignUpResponse( email: email)
            return CodeVerificationView(viewModel: viewModel)
        }
    }
    
    @MainActor
    func showSignupStatus(status: Bool) {
        let title = status ? "Sign Up verified" : "Verification Failed"
        let message = status ? "You can now sign in with your credentials" : "An error occurred while verifying your email. Please try again later."
        let actions = status ? [TextAlertAction(title: "Sign In", role: .cancel, action: { self.restart()})] : [TextAlertAction(title: "OK", role: .cancel, action: {self.router.dismiss()})]
        self.router.showAlert(title: title, message: message, actions: actions)
    }
}
