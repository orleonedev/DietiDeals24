//
//  AuctionListView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/26/25.
//

import SwiftUI

public struct AuctionListView: View {
    
    var auctionList: [AuctionCardModel]
    var mainHeader: String = ""
    var additionalInfo: String = ""
    var onTapCallBack: ((UUID) -> Void)?
    var shouldFetchMore: Bool = true
    var fetchCallBack: (() -> Void)?
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if !mainHeader.isEmpty {
                        Text(mainHeader)
                            .font(.title2)
                            .lineLimit(1)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    if !additionalInfo.isEmpty {
                        Text(additionalInfo)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                LazyVGrid(columns: columns, alignment: .center ,spacing: 32) {
                    ForEach(auctionList, id: \.id) { auction in
                        AuctionCardView(auction: auction)
                            .onTapGesture {
                                onTapCallBack?(auction.id)
                            }
                    }
                    ZStack(alignment: .center){
                        Color.clear.ignoresSafeArea(.all)
                        ProgressView()
                            .progressViewStyle(.circular)
                            .opacity(shouldFetchMore ? 1 : 0)
                            .onAppear {
                                if shouldFetchMore {
                                    fetchCallBack?()
                                }
                            }
                    }
                    .ignoresSafeArea(.all)
                }
                
            }
            .padding(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    
    @Previewable @State var auctionList: [AuctionCardModel] = AuctionCardModel.mockData
    
    AuctionListView(auctionList: auctionList, mainHeader: "AOO", additionalInfo: auctionList.count.formatted()) { auctionID in
        auctionList.append(contentsOf: AuctionCardModel.mockData)
    } fetchCallBack : {
        auctionList.append(contentsOf: AuctionCardModel.mockData)
    }
}
