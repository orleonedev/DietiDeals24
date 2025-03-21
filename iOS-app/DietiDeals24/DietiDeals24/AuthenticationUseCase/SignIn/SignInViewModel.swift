//
//  SignInViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/8/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

@Observable
class SignInViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var loginEmail: String = ""
    var loginPassword: String = ""
    var invalidLoginEmail: Bool = false
    var validationPasswordError: Bool = false
    
    var coordinator: AuthFlowCoordinator
    
    init(coordinator: AuthFlowCoordinator) {
        self.coordinator = coordinator
    }
    
    func skipAuth() async throws {
        self.isLoading = true
        try await coordinator.SignInInteractively(email: "orleone.dev+Test01@gmail.com", password: "Test123@")
        self.isLoading = false
    }
    
    func tryAuthentication() async throws {
        guard !loginEmail.isEmpty,
              !loginPassword.isEmpty
        else {
            return
        }
        isLoading = true
        try await coordinator.SignInInteractively(email: loginEmail, password: loginPassword)
        isLoading = false
    }
    
    func validateEmail() {
        let result = self.loginEmail.isValidEmail
        if !result {
            print("invalid email format")
            self.invalidLoginEmail = true
        }
    }
    
    func validatePassword() {
        let result = validatePasswordPattern(self.loginPassword)
        if !result {
            print("invalid password format")
            self.validationPasswordError = true
        }
    }
    
    private func validatePasswordPattern(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    @MainActor func goToSignUp() {
        coordinator.goToSignUp()
    }
    
    @MainActor
    func handleSignInWithApple(_ credentials: ASAuthorizationAppleIDCredential) {
        guard let authCode = credentials.authorizationCode,
              let tokenString = String(data: authCode, encoding: .utf8) else {
            print("Failed to get identity token")
            return
        }
        print("Apple authcode: \(tokenString)")
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            do {
                try await coordinator.SignInWithProvider(.apple, token: tokenString)
            } catch {
                print("Sign in with Apple failed: \(error)")
            }
        }
    }
}
