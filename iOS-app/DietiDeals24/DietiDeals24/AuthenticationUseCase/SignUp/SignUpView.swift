//
//  SignUpView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/9/25.
//

import SwiftUI

struct SignUpView: View, LoadableView {
    
    @State var viewModel: SignUpViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Create your account")
                    .font(.title)
                    .fontWeight(.semibold)
                signUpForm()
                signUpButton()
                footer()
            }
            .padding()
            
        }
        .onTapGesture {
            self.isFocused = false
        }
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    self.viewModel.dismiss()
                }
            }
        }
        .overlay {
            self.loaderView()
        }
        
        
    }
}

extension SignUpView {
    @ViewBuilder
    func signUpForm() -> some View {
        VStack(alignment: .leading, spacing: 21 ){
            
            ValidableTextField(
                validationError: self.$viewModel.validationEmailError,
                text: self.$viewModel.email, validation: self.viewModel.validateEmail,
                label: "Email".localized
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .focused(self.$isFocused)
            
            ValidableTextField(
                validationError: self.$viewModel.validationUserNameError,
                text: self.$viewModel.username, validation: self.viewModel.validateUsername,
                label: "Username".localized
            )
            .textContentType(.username)
            .keyboardType(.asciiCapable)
            .focused(self.$isFocused)

            
            VStack(alignment: .leading, spacing: 8){
                SecureValidableTextField(
                    validationError: self.$viewModel.validationPasswordError,
                    text: self.$viewModel.password, validation: self.viewModel.validatePassword,
                    label: "Password".localized
                )
                .autocorrectionDisabled(true)
                .textContentType(.newPassword)
                .focused(self.$isFocused)
                
                PasswordRequirementsView(requirements: viewModel.passwordRequirements)
                    .font(.caption)
                    .padding(.leading)
            }

            
            ValidableTextField(
                validationError: self.$viewModel.validationFullNameError,
                text: self.$viewModel.fullName,
                validation: self.viewModel.validateFullName,
                label: "Full Name".localized
            )
            .textContentType(.name)
            .keyboardType(.asciiCapable)
            .focused(self.$isFocused)

            
            ValidableDatePicker(validationError: self.$viewModel.validationBirthDateError, date: self.$viewModel.birthdate, validation: self.viewModel.validateBirthDate, label: "Birthdate".localized, range: self.viewModel.dateRange)
            
        }
    }
    
    @ViewBuilder
    func signUpButton() -> some View {
        VStack {
            Button(action: {
                viewModel.signUp()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.accent)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal)
#if DEV && DEBUG
            Button("Skip Sign Up") {
                Task{
                    do {
                        try await viewModel.skipSignUp()
                    } catch {
                        print(error)
                    }
                }
            }
            .padding()
#endif
        }
    }
    
    @ViewBuilder
    func footer() -> some View {
            VStack(alignment: .center){
                HStack(alignment: .top) {
                    Text("Signing up means you agree to our")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        
                    Button { self.onTermsAndConditions() } label: {
                        Text("Terms and Conditions")
                            .font(.caption)
                            .foregroundStyle(.accent)
                            .underline()
                    }
                }
            }
            .frame(maxWidth: .infinity)
        
    }
    
    func onTermsAndConditions() {
        
    }
    
}

#Preview {
    SignUpView(viewModel: .init(coordinator: .init(container: .init()), validator: Validator()))
}
