//
//  CodeVerificationView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/9/25.
//

import SwiftUI

struct CodeVerificationView: View, LoadableView {
    
    @State var viewModel: CodeVerificationViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ScrollView {
                VStack(alignment: .center, spacing: 32) {
                    Image(systemName: "envelope")
                        .resizable()
                        .fontWeight(.light)
                        .foregroundStyle(.accent)
                        .frame(width: size.width*0.5, height: size.width*0.3)
                    
                    
                    Text("Verify your email address")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("A code has been sent to the email address: \n**\(viewModel.emailAddress)** \nPlease enter the verification code")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
                    ValidableTextField(validationError: $viewModel.validationCodeError, text: $viewModel.confimationCode, validation: viewModel.validateCode, label: "Code".localized)
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                        .focused(self.$isFocused)
                        
                    Button {
                        viewModel.submitConfirmationCode()
                    } label: {
                        Text("Verify")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.accent)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    
                    Button("Cancel") {
                        self.viewModel.coordinator.router.dismiss(option: .toRoot)
                    }
                }
                .padding()
            }
            .onTapGesture {
                self.isFocused = false
            }
            .frame(width: size.width, height: size.height)
        }
        .overlay {
            self.loaderView()
        }
    }
}

#Preview {
    CodeVerificationView(viewModel: .init(coordinator: .init(container: .init())))
}
