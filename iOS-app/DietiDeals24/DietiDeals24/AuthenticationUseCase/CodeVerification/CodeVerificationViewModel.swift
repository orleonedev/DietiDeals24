//
//  CodeVerificationViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 13/02/25.
//

import Foundation

@Observable
class CodeVerificationViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    
    var validationCodeError: Bool = false
    var confimationCode: String = ""
    var emailAddress: String = "*@*.*"
    
    var coordinator: AuthFlowCoordinator
    
    init(coordinator: AuthFlowCoordinator) {
        self.coordinator = coordinator
    }
    
    func validateCode() {
        guard confimationCode.count == 6 else {
            validationCodeError = true
            return }
        validationCodeError = false
    }
    
    @MainActor
    func submitConfirmationCode()  {
        
        self.validateCode()
        guard self.confimationCode.count == 6 else { return }
        isLoading = true
        Task {
            do {
                try await self.coordinator.sendConfirmationCode(code: confimationCode)
                isLoading = false
                self.coordinator.showSignupStatus(status: true)
            } catch {
                print(error)
                isLoading = false
                self.coordinator.showSignupStatus(status: false)
            }
            
        }
    }
    
    func setFromSignUpResponse(email: String?) {
        if let email {
            self.emailAddress = email
        }
    }
}
