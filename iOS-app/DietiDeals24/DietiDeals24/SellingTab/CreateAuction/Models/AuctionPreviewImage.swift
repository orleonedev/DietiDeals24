//
//  AuctionPreviewImage.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/7/25.
//
import SwiftUI

struct AuctionPreviewImage: View {
    let state: AuctionImagePreviewState
    
    var body: some View {
        switch state {
            case .loading:
                ZStack {
                    Color.secondary.opacity(0.3)
                    ProgressView()
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.secondary)
                }
            case .failure:
                ZStack {
                    Color.secondary.opacity(0.3)
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                        .padding(32)
                }
            case .success(let auctionImage):
                auctionImage.image
                    .resizable()
                    .scaledToFit()
        }
        
    }
}
