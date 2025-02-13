//
//  SignUpView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/9/25.
//

import SwiftUI

struct SignUpView: View {
    
    @StateObject var viewModel: SignUpViewModel = SignUpViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Create your account")
                    .font(.title)
                    .fontWeight(.semibold)
                signUpForm()
                
            }
            .padding()
            
        }
    }
}

extension SignUpView {
    @ViewBuilder
    func signUpForm() -> some View {
        VStack(alignment: .leading, spacing: 21 ){
            
            ValidableTextField(
                validationError: self.$viewModel.validationFullNameError,
                text: self.$viewModel.fullName,
                validation: self.viewModel.validateFullName,
                label: "Full Name"
            )
            .textContentType(.name)
            .keyboardType(.asciiCapable)
            
            ValidableTextField(
                validationError: self.$viewModel.validationUserNameError,
                text: self.$viewModel.username, validation: self.viewModel.validateUsername,
                label: "Username"
            )
            .textContentType(.username)
            .keyboardType(.asciiCapable)
            
            ValidableTextField(
                validationError: self.$viewModel.validationEmailError,
                text: self.$viewModel.email, validation: self.viewModel.validateEmail,
                label: "Email"
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            
            SecureValidableTextField(
                validationError: self.$viewModel.validationPasswordError,
                text: self.$viewModel.password, validation: self.viewModel.validatePassword,
                label: "Password"
            )
            .textContentType(.password)
            .autocorrectionDisabled(true)
            
        }
        
    }
}

#Preview {
    SignUpView()
}
