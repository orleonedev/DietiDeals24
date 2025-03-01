//
//  SellingMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//


import SwiftUI

struct SellingMainView: View, LoadableView {
    
    @State var viewModel: SellingMainViewModel
    
    var body: some View {
        VStack {
            if !viewModel.isSeller {
                becomeSellerView()
            } else {
                startSellingView()
            }
        }
        .padding()
        .task {
            await viewModel.checkSellerStatus()
        }
        .navigationTitle("Sell")
        
    }
}


extension SellingMainView {
    
    @ViewBuilder
    func becomeSellerView() -> some View {
        VStack(spacing: 48) {
            VStack(spacing: 0){
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                    .foregroundStyle(.dietiYellow)
                
                Text("Start Selling on \nDietiDeals24")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundStyle(.dietiYellow)
            }
            
            Text("Join our seller community and start listing your items for auction. Tap the button below to begin.")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.primary)
            
            Button(action: {
                viewModel.becomeASeller()
            }) {
                Text("Start Selling")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.accent)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 32)
            }
            
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    func startSellingView() -> some View {
        VStack(spacing: 48) {
            VStack(spacing: 0){
                Image(systemName: "tag")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                    .foregroundStyle(.dietiYellow)
                
                Text("Welcome, Seller!")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .foregroundStyle(.dietiYellow)
            }
            
            Text("Ready to create your next auction? Tap the button below to get started with listing your items.")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.primary)
            
            Button(action: {
                viewModel.createAuction()
            }) {
                Text("Create Auction")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.accent)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 32)
            }
            
        }
        .padding(.vertical)
        
    }
}

#Preview {
    SellingMainView(viewModel: .init(sellingCoordinator: .init(appContainer: .init())))
}
