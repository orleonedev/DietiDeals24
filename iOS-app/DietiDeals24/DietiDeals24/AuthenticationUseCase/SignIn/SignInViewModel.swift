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
    let validator: Validator
    var coordinator: AuthFlowCoordinator
    
    
    init(coordinator: AuthFlowCoordinator, validator: Validator) {
        self.coordinator = coordinator
        self.validator = validator
    }
    
    func skipAuth() async throws {
        self.isLoading = true
        try await coordinator.SignInInteractively(email: "orleone.dev+Test01@gmail.com", password: "Test123@")
        self.isLoading = false
    }
    
    func tryAuthentication() async throws {
        let validationErrors = validator.validateEmailAndPassword(email: self.loginEmail, password: self.loginPassword)
        guard validationErrors.isEmpty else {
            self.validationPasswordError = validationErrors.contains(where: { $0 == .emptyPassword || $0 == .invalidPassword})
            self.invalidLoginEmail = validationErrors.contains(where: { $0 == .emptyEmail || $0 == .invalidEmail})
            return
        }
        isLoading = true
        try await coordinator.SignInInteractively(email: loginEmail, password: loginPassword)
        isLoading = false
    }
    
    func validateEmail() {
        let isValid = validator.isValidEmail(self.loginEmail)
        if !isValid {
            print("invalid email format")
            self.invalidLoginEmail = true
        }
    }
    
    func validatePassword() {
        let isValid = validator.validatePassword(self.loginPassword)
        if !isValid {
            print("invalid password format")
            self.validationPasswordError = true
        }
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
