//
//  SignInViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/8/25.
//

import Foundation
import SwiftUI

class SignInViewModel: ObservableObject {
    
    @Published var isAuthenticated: Bool = false
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""
    @Published var invalidLoginEmail: Bool = false
    @Published var validationPasswordError: Bool = false
    
    func tryAuthentication() {
        guard !loginEmail.isEmpty,
              !loginPassword.isEmpty
        else {
            return
        }
        isAuthenticated = true
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
}
