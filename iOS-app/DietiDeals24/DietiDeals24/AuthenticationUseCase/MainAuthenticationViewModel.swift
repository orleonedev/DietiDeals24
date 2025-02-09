//
//  MainAuthenticationViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/8/25.
//

import Foundation
import SwiftUI

class MainAuthenticationViewModel: ObservableObject {
    
    @Published var isAuthenticated: Bool = false
    @Published var loginEmail: String = "" {
        willSet {
            invalidLoginEmail = false
        }
    }
    @Published var loginPassword: String = ""
    
    @Published var invalidLoginEmail: Bool = false
    
    @Published var signupForm: signUpFormModel = signUpFormModel()
    @Published var confimationCode: String? = nil
    
    func tryAuthentication() {
        guard !loginEmail.isEmpty,
              !loginPassword.isEmpty
        else {
            return
        }
        isAuthenticated = true
    }
}

struct signUpFormModel {
    var email: String = ""
    var password: String = ""
    var fullName: String = ""
    var username: String = ""
    var birthdate: Date?
}
