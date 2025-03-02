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
            .scrollBounceBehavior(.basedOnSize)
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
            if !auction.baseDetail.images.isEmpty {
                self.horizontalImageStack(images: auction.baseDetail.images)
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
                descriptionView()
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
                Text("\(timer)" + " Hour\(timer == 1 ? "" : "s")")
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
    
    @ViewBuilder
    func descriptionView() -> some View {
        VStack(alignment: .leading, spacing: 12){
            Text("Description")
                .font(.headline)
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam auctor quam id massa faucibus dignissim. Nullam eget metus id nisl malesuada condimentum. Nam viverra fringilla erat, ut fermentum nunc feugiat eu.")
                .font(.body)
                .lineLimit(nil)
                .padding()
                .background(.secondary.quinary)
                .clipShape(.rect(cornerRadius: 12))
        }
        
    }
    
    @ViewBuilder
    func horizontalImageStack(images: [String] ) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 24) {
                ForEach(images, id: \.self) { image in
                    GeometryReader { proxy in
                        RemoteImage(urlString: image)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .aspectRatio(1.77, contentMode: .fit)
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .scrollBounceBehavior(.basedOnSize)
        .frame(height: 192)
        
    }
}

#Preview {
    
    
    
    @Previewable @State var vm: AuctionPreviewViewModel =  .init(sellingCoordinator: .init(appContainer: .init()))
    let imgUrl = "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f"
    vm.setAuction(
        CreateAuctionModel(
            baseDetail: .init(
                title: "Title" ,
                description: "gdgsgsgsrgrsgrs",
                category: AuctionCategory.Electronics,
                images: [
                    imgUrl,
                    imgUrl
                ]
            ),
            auctionType: .descending,
            startingPrice:  1200.0,
            threshold: 12,
            timer: 4,
            secretPrice: 200
        )
    )
    
    return NavigationStack{AuctionPreviewView(viewModel: vm)}
}
