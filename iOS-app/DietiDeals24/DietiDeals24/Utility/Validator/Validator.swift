//
//  Validator.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/15/25.
//

import Foundation

struct Validator {
    
    enum ValidationError: LocalizedError, Equatable {
        case invalidEmail
        case invalidPassword
        case emptyEmail
        case emptyPassword
    }
    
    
    func validateEmailAndPassword(email: String, password: String) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if email.isEmpty {
            errors.append(.emptyEmail)
        } else if !isValidEmail(email) {
            errors.append(.invalidEmail)
        }
        
        if password.isEmpty {
            errors.append(.emptyPassword)
        } else if !validatePassword(password) {
            errors.append(.invalidPassword)
        }
        
        return errors
    }
    
    // MARK: valid email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // MARK: valid password
    func validatePassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialChar = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil
        
        return hasUppercase && hasLowercase && hasNumber && hasSpecialChar
    }
    
    func isValidBirthdate(_ birthdate: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // Calcola la data esattamente 18 anni fa
        if let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: today) {
            return birthdate <= eighteenYearsAgo
        }
        
        return false
    }
    
}
