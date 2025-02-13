//
//  SignUpViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 13/02/25.
//

import Foundation

class SignUpViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var fullName: String = ""
    @Published var username: String = ""
    @Published var birthdate: Date? = nil
    @Published var validationEmailError: Bool = false
    @Published var validationPasswordError: Bool = false
    @Published var validationFullNameError: Bool = false
    @Published var validationUserNameError: Bool = false
    @Published var validationBirthDateError: Bool = false
    
    private var isFormValid: Bool {
        self.validateFields()
        return !validationEmailError && !validationPasswordError && !validationFullNameError && !validationUserNameError && !validationBirthDateError
    }
    
    private func validateFields() {
        validationEmailError = !self.email.isValidEmail
        validationPasswordError = !self.validatePassword(self.password)
        validationFullNameError = self.fullName.isEmpty
        validationUserNameError = self.username.isEmpty
        validationBirthDateError = self.birthdate == nil
    }
    
    func validateEmail() {
        validationEmailError = !self.email.isValidEmail
    }
    
    func validatePassword() {
        validationPasswordError = !self.validatePassword(self.password)
    }
    
    func validateUsername() {
        validationUserNameError = self.username.isEmpty
    }
    
    func validateFullName() {
        validationFullNameError = self.fullName.isEmpty
    }
    
    func validateBirthDate() {
        validationBirthDateError = self.birthdate == nil || !self.isValidBirthdate(self.birthdate ?? .now)
    }
    
    private func isValidBirthdate(_ birthdate: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        // Calcola la data esattamente 18 anni fa
        if let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: today) {
            return birthdate <= eighteenYearsAgo
        }
        
        return false
    }
    
    private func validatePassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    
}
