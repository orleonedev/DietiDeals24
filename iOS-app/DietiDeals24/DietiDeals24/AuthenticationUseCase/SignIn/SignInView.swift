//
//  SignInView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/6/25.
//

import SwiftUI
import AuthenticationServices
import RoutingKit

struct SignInView: View {
    
    @State var viewModel: SignInViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .clipShape(.rect(cornerRadius: 128/6.4))
                Spacer()
                loginView()
                noAccountView()
                socialLoginStack()
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        
    }
}

extension SignInView {
    
    @ViewBuilder
    func loginView() -> some View {
        VStack(alignment: .leading, spacing: 32){
            loginForm()
            loginButton()
        }
    }
    
    @ViewBuilder
    func loginForm() -> some View {
        VStack(alignment: .leading, spacing: 16 ){
            VStack(alignment: .leading, spacing: 4){
                ValidableTextField(validationError: self.$viewModel.invalidLoginEmail, text: self.$viewModel.loginEmail, validation: self.viewModel.validateEmail, label: "Email")
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
            }
            
            SecureValidableTextField(
                validationError: self.$viewModel.validationPasswordError,
                text: self.$viewModel.loginPassword,
                validation: self.viewModel.validatePassword, label: "Password"
            )
            .textContentType(.password)
            .autocorrectionDisabled(true)
            
        }
        
    }
    
    @ViewBuilder
    func loginButton() -> some View {
        VStack {
            Button(action: {
                Task{
                    do {
                        try await viewModel.tryAuthentication()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Text("Sign In")
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
            Button("Skip Sign In") {
                Task{
                    do {
                        try await viewModel.skipAuth()
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
    func noAccountView() -> some View {
        HStack(alignment: .center, spacing: 8){
            Text("Don't have an account?")
            Button {
                self.viewModel.goToSignUp()
            } label: {
                Text("Sign Up")
                    .foregroundStyle(.accent)
            }
        }
        .font(.subheadline)
    }
    
    @ViewBuilder
    func socialLoginStack() -> some View {
        VStack(spacing: 16){
            HStack{
                VStack{
                    Divider()
                }
                Text("Or sign in with")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack{
                    Divider()
                }
            }
            VStack {
                signInWithApple()
                    .frame(height: 44)
               // signInWithGoogle()
               // signInWithFacebook()
            }
            .padding(.horizontal)
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
    }
    
    @ViewBuilder
    func signInWithApple() -> some View {
        
        AuthenticationServices.SignInWithAppleButton(.signIn) { request in
            
        } onCompletion: { result in
            
        }
        .signInWithAppleButtonStyle(.whiteOutline)
    }
}

extension SignInView {
        
    func onTermsAndConditions() {
        
    }
}

#Preview {
    SignInView(
        viewModel: .init(
            coordinator: .init(container: .init())
        )
    )
}


