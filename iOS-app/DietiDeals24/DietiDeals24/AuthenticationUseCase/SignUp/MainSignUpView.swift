//
//  MainSignUpView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/9/25.
//

import SwiftUI

struct MainSignUpView: View {
    
    @ObservedObject var viewModel: MainAuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                Text("Create your account")
                    .font(.title)
                
                signUpForm()
                
            }
            
        }
    }
}

extension MainSignUpView {
    @ViewBuilder
    func signUpForm() -> some View {
        VStack(alignment: .leading, spacing: 16 ){
            
            //            ValidableTextField(validationError: self.$viewModel.invalidLoginEmail, text: self.$viewModel.loginEmail, label: "Email")
            //                .textContentType(.emailAddress)
            //                .keyboardType(.emailAddress)
            //                .onSubmit(of: .text) {
            //                    let result = self.validateEmail(viewModel.loginEmail)
            //                    if !result {
            //                        print("invalid email format")
            //                        self.viewModel.invalidLoginEmail = true
            //                    }
            //                }
            
            VStack(alignment: .leading, spacing: 4){
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                SecureField("Password", text: $viewModel.signupForm.password)
                    .autocorrectionDisabled(true)
                    .textContentType(.password)
                    .textFieldStyle( TextFieldRoundedCornerStyleClear())
            }
        }
        
    }
}

#Preview {
    MainSignUpView(viewModel: .init())
}
