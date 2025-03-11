//
//  AuctionPreviewView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

public struct AuctionPreviewView: View, LoadableView {
    
    @State var viewModel: AuctionPreviewViewModel
    
    public var body: some View {
        VStack(spacing: 0){
            ProgressView(value: 3, total: 4)
            ScrollView {
                if let auction = self.viewModel.auction {
                    auctionPreview(auction: auction)
                    Spacer()
                        .frame(height: 100)
                }
            }
            .overlay {
                ZStack(alignment: .bottom){
                    Color.clear
                    
                    Button(action: {
                        viewModel.publishAuction()
                    }) {
                        Text("Publish Auction")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.accent)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .padding()
                    .padding()
                    .background(.ultraThinMaterial)
                }
                
                .ignoresSafeArea()
            }
            
        }
        .interactiveDismissDisabled(true)
        .navigationTitle(self.viewModel.auction?.baseDetail.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Cancel") {
                    self.viewModel.tryToDismiss()
                }
            }
        }
        .overlay {
            loaderView()
        }
    }
}

extension AuctionPreviewView {
    
    @ViewBuilder
    func tagHorizontalStack(auction: CreateAuctionModel) -> some View {
        HStack(spacing: 12) {
            if let category = auction.baseDetail.category {
                Text(category.label)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(10)
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                    .background{Color.accent.brightness(-0.2)}
                    .clipShape(.capsule)
            }
            
            Text(auction.auctionType.label)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(10)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .background{Color.accent.brightness(-0.2)}
                .clipShape(.capsule)
        }
    }
    
    @ViewBuilder
    func auctionPreview(auction: CreateAuctionModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !auction.baseDetail.imagesPreview.isEmpty {
                self.horizontalImageStack(images: auction.baseDetail.imagesPreview)
            } else {
                GeometryReader { proxy in
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(32)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .clipShape(.rect(cornerRadius: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(height: 192)
                .aspectRatio(1.77, contentMode: .fit)
                .background(.secondary.quaternary)
                .clipShape(.rect(cornerRadius: 24))
                .padding()
            }
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 12){
                    Text(auction.baseDetail.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    tagHorizontalStack(auction: auction)
                }
                priceStack(auction.startingPrice)
                timerAndThresholdStack(timer: auction.timer, threshold: auction.threshold)
                if let secrePrice = auction.secretPrice, auction.auctionType == .descending {
                    secrePriceRow(secrePrice)
                }
                descriptionView(auction.baseDetail.description)
            }
            .padding(.horizontal)
            
        }
    }
    
    
    @ViewBuilder
    func secrePriceRow(_ secretPrice: Double) -> some View {
        HStack {
            Text("Secret Price")
                .font(.body)
            Spacer()
            Text("\(secretPrice.formatted()) €")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
        }
        .padding()
        .background(.secondary.quinary)
        .clipShape(.rect(cornerRadius: 12))
    }
    
    @ViewBuilder
    func priceStack(_ price: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Starting Price")
                .font(.body)
            Text("\(price.formatted()) €")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.accent)
        }
    }
    
    @ViewBuilder
    func timerAndThresholdStack(timer: Int, threshold: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Timer")
                    .font(.body)
                Spacer()
                Text(formatTimer(timer))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
            }
            HStack {
                Text("Threshold")
                    .font(.body)
                Spacer()
                Text("\(threshold.formatted()) €")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
            }
        }
    }
    
    private func formatTimer(_ hours: Int) -> String {
        
        let timer: Int = hours*60*60
        
        if timer > 86400 {
            // More than 1 day: show day and hours.
            let days = Int(timer) / 86400
            let hours = (Int(timer) % 86400) / 3600
            return "\(days) day\(days != 1 ? "s" : ""), \(hours)h"
        } else {
            // More than 1 hour: show hours and minutes.
            let hours = Int(timer) / 3600
            let minutes = (Int(timer) % 3600) / 60
            return "\(hours)h \(minutes)m"
        }

    }
    
    @ViewBuilder
    func descriptionView(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 12){
            Text("Description")
                .font(.headline)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondary.quinary)
                .clipShape(.rect(cornerRadius: 12))
                
        }
        
    }
    
    @ViewBuilder
    func horizontalImageStack(images: [AuctionImagePreviewState] ) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 24) {
                ForEach(images, id: \.self) { preview in
                    GeometryReader { proxy in
                        AuctionPreviewImage(state: preview)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .background(.quaternary)
                            .clipped()
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .aspectRatio(1.77, contentMode: .fit)
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .frame(height: 192)
        
    }
}

#Preview {
    
    
    
    @Previewable @State var vm: AuctionPreviewViewModel =  .init(sellingCoordinator: .init(appContainer: .init()), auctionService: DefaultAuctionService(rest: DefaultRESTDataSource()))
    let imgUrl = "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f"
    vm.setAuction(
        CreateAuctionModel(
            baseDetail: .init(
                title: "Title" ,
                description: "gdgsgsgsrgrsgrs",
                category: AuctionCategory.Electronics,
                imagesPreview: [
                    .success(AuctionImage(image: Image(systemName: "photo").resizable(), data: Data()))
                ]
            ),
            auctionType: .descending,
            startingPrice:  1200.0,
            threshold: 12,
            timer: 4,
            secretPrice: 200
        )
    )
    
     return AuctionPreviewView(viewModel: vm)
}
