//
//  UserProfileView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/6/25.
//

import SwiftUI

struct UserProfileView: View, LoadableView {
    
    @State var viewModel: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                UserDetailView(userModel: viewModel.userDataModel, isPersonalAccount: viewModel.isPersonalProfile)
                    .padding(.horizontal)
                Divider()
                Spacer()
                    .frame(height: 32)
                if viewModel.userDataModel?.role == .seller {
                    AuctionListView(
                        auctionList: viewModel.vendorItems,
                        mainHeader: "Active Auctions",
                        additionalInfo: viewModel.vendorItemsCount.formatted(),
                        onTapCallBack: viewModel.getAuctionDetail,
                        shouldFetchMore: viewModel.shouldFetchMoreVendorItem,
                        fetchCallBack: viewModel.getMoreVendorItems
                    )
                    .task {
                        if viewModel.vendorItems.isEmpty {
                            viewModel.getMoreVendorItems()
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(viewModel.userDataModel?.username ?? "")
        .overlay {
            self.loaderView()
        }
    }
}
