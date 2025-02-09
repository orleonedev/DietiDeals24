//
//  SwiftUIView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/6/25.
//

import SwiftUI
import AuthenticationServices

struct MainAuthenticationView: View {
    
    @ObservedObject var viewModel: MainAuthenticationViewModel
    
    init(viewModel: MainAuthenticationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    Image("AppIconImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128, height: 128)
                        .clipShape(.rect(cornerRadius: 128/6.4))
                    Text("authStatus: \(viewModel.isAuthenticated ? "authenticated" : "not authenticated")")
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

extension MainAuthenticationView {
    
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
                ValidableTextField(validationError: self.$viewModel.invalidLoginEmail, text: self.$viewModel.loginEmail, label: "Email")
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .onSubmit(of: .text) {
                        let result = viewModel.loginEmail.isValidEmail
                        if !result {
                            print("invalid email format")
                            self.viewModel.invalidLoginEmail = true
                        }
                    }
            }
            VStack(alignment: .leading, spacing: 4){
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                SecureField("Password", text: $viewModel.loginPassword)
                .autocorrectionDisabled(true)
                .textContentType(.password)
                .textFieldStyle( TextFieldRoundedCornerStyleClear())
            }
        }
        
    }
    
    @ViewBuilder
    func loginButton() -> some View {
        VStack {
            Button(action: {
                viewModel.tryAuthentication()
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
                viewModel.isAuthenticated = true
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
               // signInWithGoogle()
               // signInWithFacebook()
            }
            .padding(.horizontal)
            Spacer()
            VStack{
                HStack(alignment: .top) {
                    Text("Creating an account means you agree to our")
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
            
        }
    }
    
    @ViewBuilder
    func signInWithApple() -> some View {
        
        AuthenticationServices.SignInWithAppleButton(.signIn) { request in
            
        } onCompletion: { result in
            
        }
        .signInWithAppleButtonStyle(.whiteOutline)
        .frame(maxHeight: 44)
    }
}

extension MainAuthenticationView {
        
    func onTermsAndConditions() {
        
    }
}

#Preview {
    @Previewable @State var vm: MainAuthenticationViewModel = .init()
    MainAuthenticationView(viewModel: vm )
}


