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
    
    let passwordRequirements: [String] = ["At least one uppercase letter", "At least one lowercase letter", "At least one digit", "At least one special character", "Minimum length of 8 characters"]
    
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
    let validator: Validator
    
    init(coordinator: AuthFlowCoordinator, validator: Validator) {
        self.coordinator = coordinator
        self.validator = validator
    }
    
    var isFormValid: Bool {
        return !validationEmailError && !validationPasswordError && !validationFullNameError && !validationUserNameError && !validationBirthDateError
    }
    
    private func validateFields() {
        let emailAndPasswordErrors = validator.validateEmailAndPassword(email: self.email, password: self.password)
        self.validationPasswordError = emailAndPasswordErrors.contains(where: { $0 == .emptyPassword || $0 == .invalidPassword})
        self.validationEmailError = emailAndPasswordErrors.contains(where: { $0 == .emptyEmail || $0 == .invalidEmail})
        validationFullNameError = self.fullName.isEmpty
        validationUserNameError = self.username.isEmpty
        self.validateBirthDate()
    }
    
    func validateEmail() {
        validationEmailError = !validator.isValidEmail(self.email)
    }
    
    func validatePassword() {
        validationPasswordError = !validator.validatePassword(self.password)
    }
    
    func validateUsername() {
        validationUserNameError = self.username.isEmpty
    }
    
    func validateFullName() {
        validationFullNameError = self.fullName.isEmpty
    }
    
    func validateBirthDate() {
        validationBirthDateError = !validator.isValidBirthdate(self.birthdate)
    }
    
    
    @MainActor
    public func signUp() {
        validateFields()
        guard isFormValid else { return }
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
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
            } catch {
                print(error)
            }
        }
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
