//
//  TypedAuctionDetailView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

public struct TypedAuctionDetailView: View, LoadableView {
    
    @State var viewModel: TypedAuctionDetailViewModel
    @FocusState private var isFocused: Bool
    
    public var body: some View {
        VStack(spacing: 0){
            ProgressView(value: 2, total: 4)
            ScrollView {
                VStack(spacing: 32) {
                    
                    Picker("Auction Type", selection: $viewModel.auctionType) {
                        ForEach(Array(AuctionType.allCases.dropFirst()), id: \.self) { type in
                            Text(type.label)
                        }
                    }
                    .pickerStyle(.segmented)
                    formFields()
                    nextButton()
                }
                .padding()
            }
            .onTapGesture {
                self.isFocused = false
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .animation(.easeInOut, value: viewModel.auctionType)
        .interactiveDismissDisabled(true)
        .navigationTitle(self.viewModel.baseAuction?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Cancel") {
                    self.viewModel.tryToDismiss()
                }
            }
        }
        
    }
}

extension TypedAuctionDetailView {
    
    @ViewBuilder
    func formFields() -> some View {
        VStack(alignment: .leading,spacing: 21) {
            
            ValidableTextField(validationError: $viewModel.startingPriceValidationError, text: $viewModel.startingPrice, validation: viewModel.validateStartingPrice, label: "Starting Price" )
            .keyboardType(.decimalPad)
            .focused(self.$isFocused)
            
            ValidableTextField(validationError: $viewModel.timerValidationError, text: $viewModel.timer, validation: viewModel.validateTimer, label: "Timer (min 1h)" )
            .keyboardType(.decimalPad)
            .focused(self.$isFocused)
            
            ValidableTextField(validationError: $viewModel.thresholdValidationError, text: $viewModel.threshold, validation: viewModel.validateThreshold, label: "Threshold (min. 1)" )
                .keyboardType(.numberPad)
            .focused(self.$isFocused)
            
            if self.viewModel.auctionType == .descending {
                ValidableTextField(validationError: $viewModel.secretPriceValidationError, text: $viewModel.secretPrice, validation: viewModel.validateSecretPrice, label: "Secret Price" )
                    .keyboardType(.decimalPad)
                .focused(self.$isFocused)
                .transition(.opacity)
            }
            
        }
        
    }
    
    @ViewBuilder
    func nextButton() -> some View {
        Button(action: {
            self.viewModel.goToAuctionPreview()
        }) {
            Text("Next")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.accent)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

#Preview {
    TypedAuctionDetailView(viewModel: .init(sellingCoordinator: .init(appContainer: .init())))
}
