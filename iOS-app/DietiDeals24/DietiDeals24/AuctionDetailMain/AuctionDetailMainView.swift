//
//  AuctionDetailMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

public struct AuctionDetailMainView: View, LoadableView {
    
    @State var viewModel: AuctionDetailMainViewModel
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16){
                
                if let auction = viewModel.auction {
                    ViewThatFits(in: .horizontal, content: {
                        Text(auction.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(auction.title)
                            .font(.title2)
                            .lineLimit(3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                    })
                        .padding(.horizontal)
                        .padding(.top)
                    AuctionDetailView(auction: auction, isPersonalAuction: viewModel.isPersonalAcution)
                        .padding(.bottom)
                }
                if !viewModel.isPersonalAcution, let vendorName = self.viewModel.auction?.vendor.username, let vendorID = self.viewModel.auction?.vendor.id {
                    Divider()
                    vendorStack(vendorName)
                        .onTapGesture {
                            self.viewModel.showVendorProfile(id: vendorID)
                        }
                    Spacer()
                        .frame(height: 100)
                }
                
            }
        }
        .animation(.easeInOut, value: viewModel.auction)
        .task {
            viewModel.checkAuctionOwnership()
        }
        .overlay {
            if !viewModel.isPersonalAcution && viewModel.auction?.state == .open {
                presetOfferOverlay()
            }
        }
        .overlay {
            loaderView()
        }
        
    }
    
}

extension AuctionDetailMainView {
    
    @ViewBuilder
    func vendorStack(_ vendor: String) -> some View {
        VStack(alignment: .center, spacing: 4){
            Image(systemName: "person.badge.shield.checkmark.fill")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white )
                .background(Color.uninaBlu)
                .clipShape(Circle())
                .frame(width: 80, height: 80)
            Spacer()
                .frame(height: 8)
            
            Text(vendor)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .padding()
        .frame(maxWidth: .infinity)
        .background(.quinary)
        .clipShape(.rect(cornerRadius: 24))
        .padding()
    }
    
    @ViewBuilder
    func presetOfferOverlay() -> some View {
        ZStack(alignment: .bottom){
            Color.clear
            
            Button(action: {
                viewModel.showPresentOfferSheet()
            }) {
                Text("Present Offer")
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
    }
}

#Preview {
    
    @Previewable @State var vm: AuctionDetailMainViewModel =  .init(auctionCoordinator: ExploreCoordinator(appContainer: .init()), vendorService: DefaultVendorService(rest: DefaultRESTDataSource()), auctionService: DefaultAuctionService(rest: DefaultRESTDataSource()))
    let imgUrl = "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f"
    vm.setAuction(
        AuctionDetailModel(
            id: UUID(),
            title: "Medium Size Title for an auction",
            description: "long description long description long description long description long description long description long description long description long description long description long description long description long description long description ",
            category: .Furniture,
            images: [],
            auctionType: .incremental,
            currentPrice: 12345.0,
            threshold: 123.0,
            timer: 2,
            secretPrice: nil,
            startDate: .now.advanced(by: -60*60),
            endTime: .now.advanced(by: 60*60),
            vendor: VendorAuctionDetail(id: UUID(), name: "Test Vendor Name", username: "Test Vendor Name Test Vendor Name Test Vendor Name Test Vendor Name", email: "test@test.com", successfulAuctions: 0, joinedSince: .now),
            state: .expired,
            bidsCount: 0
        )

    )
    
    return NavigationStack{
        AuctionDetailMainView(viewModel: vm)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {}
                }
            } }
    
    
}
