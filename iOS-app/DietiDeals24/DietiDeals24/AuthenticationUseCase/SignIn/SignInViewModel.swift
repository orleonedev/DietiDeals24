//
//  SignInViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/8/25.
//

import Foundation
import SwiftUI

@Observable
class SignInViewModel {
    
    var loginEmail: String = ""
    var loginPassword: String = ""
    var invalidLoginEmail: Bool = false
    var validationPasswordError: Bool = false
    
    var coordinator: AuthFlowCoordinator
    
    init(coordinator: AuthFlowCoordinator) {
        self.coordinator = coordinator
    }
    
    func skipAuth() async throws {
        try await coordinator.SignInInteractively(email: "orleone.dev+Test01@gmail.com", password: "Test123@")
    }
    
    func tryAuthentication() async throws {
        guard !loginEmail.isEmpty,
              !loginPassword.isEmpty
        else {
            return
        }
        try await coordinator.SignInInteractively(email: loginEmail, password: loginPassword)
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
}
