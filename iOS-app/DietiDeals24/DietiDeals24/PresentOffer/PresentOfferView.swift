//
//  PresentOfferView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/7/25.
//

import SwiftUI

struct PresentOfferView: View, LoadableView {
    
    @State var viewModel: PresentOfferViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            if let auction = viewModel.auctionDetails {
                if auction.auctionType == .incremental {
                    incrementalBid()
                } else {
                    descendingBid()
                }
                
                Spacer()
                
                Button {
                    viewModel.submitBid()
                } label: {
                    Text("Place Bid")
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
        .contentShape(Rectangle())
        .onTapGesture {
            self.isFocused = false
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.dismiss()
                }
            }
        }
        .navigationTitle("Place a Bid")
        .navigationBarTitleDisplayMode(.inline)
        .presentationDetents([.medium])
        .overlay {
            loaderView()
        }
        
    }
}

extension PresentOfferView {
    
    @ViewBuilder
    func incrementalBid() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ValidableTextField(validationError: $viewModel.priceValidationError, text: $viewModel.bidPriceString, validation: viewModel.validatePrice, label: "Your Bid")
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .onChange(of: viewModel.bidPriceString) { _, newValue in
                    viewModel.validatePrice()
                }
            
            VStack(alignment: .leading, spacing: 4){
                Text("Current Price: \(viewModel.auctionDetails?.currentPrice.formatted() ?? "") €")
                Text("Threshold: \(viewModel.auctionDetails?.threshold.formatted() ?? "") €")
            }
            .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    func descendingBid() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your about to bid")
                .font(.body)
                .foregroundStyle(.secondary)
            Text("\(viewModel.auctionDetails?.currentPrice.formatted() ?? "") €")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.accent)
                .frame(maxWidth: .infinity)
        }
        
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = true
    @Previewable @State var vm: PresentOfferViewModel = .init(auctionCoordinator: ExploreCoordinator(appContainer: .init()), bidService: DefaultBidService(rest: DefaultRESTDataSource()))
    vm.setAuctionDetials(
        AuctionDetailModel(
            id: UUID(),
            title: "Title",
            description: "Description",
            category: .Electronics,
            images: [],
            auctionType: .incremental,
            currentPrice: 150.0,
            threshold: 15.0,
            timer: 23,
            secretPrice: 50.0,
            endTime: .now.advanced(by: .hours(23)),
            vendor: VendorAuctionDetail(id: UUID(), name: "Test", username: "Test", email: "test@test.com", successfulAuctions: 0, joinedSince: .now)
        ),
        onBidResult: { _ in }
    )
    
      return VStack{
        VStack{
            Color.accentColor.ignoresSafeArea()
        }.sheet(isPresented: $isPresented) {
            NavigationStack {
                PresentOfferView(viewModel: vm)
            }
        }
        
    }
}

extension TimeInterval {
    static func hours(_ hours: Int) -> TimeInterval {
        return TimeInterval(hours) * 60 * 60
    }
}
