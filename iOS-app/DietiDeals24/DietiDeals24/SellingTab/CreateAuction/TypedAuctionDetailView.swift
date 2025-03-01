//
//  TypedAuctionDetailView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

public struct TypedAuctionDetailView: View, LoadableView {
    
    @State var viewModel: TypedAuctionDetailViewModel
    
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
            .scrollBounceBehavior(.basedOnSize)
        }
        .interactiveDismissDisabled(true)
        .navigationTitle(self.viewModel.baseAuction?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

extension TypedAuctionDetailView {
    
    @ViewBuilder
    func formFields() -> some View {
        VStack(alignment: .leading,spacing: 21) {
            
            ValidableTextField(validationError: .constant(false), text: $viewModel.startingPrice, validation: {
                
            }, label: "Starting Price" )
            .keyboardType(.decimalPad)
            
            
            if self.viewModel.auctionType == .descending {
                ValidableTextField(validationError: .constant(false), text: $viewModel.secretPrice, validation: {
                    
                }, label: "Secret Price" )
                .keyboardType(.decimalPad)
                .transition(.opacity)
            }
            
        }
        .animation(.easeInOut, value: viewModel.auctionType)
    }
    
    @ViewBuilder
    func nextButton() -> some View {
        Button(action: {
            
        }) {
            
        }
        
    }
}

