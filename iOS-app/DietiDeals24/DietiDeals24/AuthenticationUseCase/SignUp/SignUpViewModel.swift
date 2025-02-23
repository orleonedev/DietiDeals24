//
//  SignUpViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 13/02/25.
//

import Foundation

@Observable
class SignUpViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    
    var email: String = ""
    var password: String = ""
    var fullName: String = ""
    var username: String = ""
    var birthdate: Date = .now
    var validationEmailError: Bool = false
    var validationPasswordError: Bool = false
    var validationFullNameError: Bool = false
    var validationUserNameError: Bool = false
    var validationBirthDateError: Bool = false
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = Calendar.current.dateComponents([.year, .month, .day], from: .distantPast)
        let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: .now)!
        let endComponents = Calendar.current.dateComponents([.year, .month, .day], from: eighteenYearsAgo)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var coordinator: AuthFlowCoordinator
    
    init(coordinator: AuthFlowCoordinator) {
        self.coordinator = coordinator
    }
    
    private var isFormValid: Bool {
        self.validateFields()
        return !validationEmailError && !validationPasswordError && !validationFullNameError && !validationUserNameError && !validationBirthDateError
    }
    
    private func validateFields() {
        validationEmailError = !self.email.isValidEmail
        validationPasswordError = !self.validatePassword(self.password)
        validationFullNameError = self.fullName.isEmpty
        validationUserNameError = self.username.isEmpty
        self.validateBirthDate()
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
        validationBirthDateError = !self.isValidBirthdate(self.birthdate)
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
    
    
    public func signUp() async throws {
        isLoading = true
        try await coordinator.signUp(
            model: UserSignUpAttributes(
                username: self.username,
                email: self.email,
                password: self.password,
                preferredUsername: self.username,
                name: self.fullName,
                birthdate: self.birthdate
            )
        )
        isLoading = false
    }
    
    public func skipSignUp() async throws {
        isLoading = true
        try await coordinator.signUp(
            model: UserSignUpAttributes(
                username: "signUpSkip",
                email: "orleone.dev+SignUpSkip@gmail.com",
                password: "Test123@",
                preferredUsername: "signUpSkip",
                name: "signUpSkip Name",
                birthdate: Calendar.current.date(byAdding: .year, value: -19, to: .now) ?? .distantPast
            )
        )
        isLoading = false
    }
    
    @MainActor
    public func dismiss() {
        coordinator.goBack()
    }
}
