//
//  UserAreaMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI

struct UserAreaMainView: View, LoadableView {
    
    @State var viewModel: UserAreaMainViewModel
    
    init(viewModel: UserAreaMainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                UserDetailView(userModel: viewModel.userDataModel, isPersonalAccount: true)
            }
            .padding()
            if viewModel.userDataModel?.role == .seller {
                AuctionListView(
                    auctionList: viewModel.vendorItems,
                    mainHeader: "My Active Auctions",
                    additionalInfo: viewModel.vendorItemsCount.formatted(),
                    onTapCallBack: viewModel.getAuctionDetail,
                    shouldFetchMore: viewModel.shouldFetchMoreVendorItem,
                    fetchCallBack: viewModel.getMoreVendorItems
                )
                .refreshable {
                    viewModel.refreshVendorItems()
                }
                .scrollBounceBehavior( viewModel.vendorItems.isEmpty ? .basedOnSize : .automatic)
                .task {
                    if viewModel.vendorItems.isEmpty {
                        viewModel.refreshVendorItems()
                    }
                }
            }
        }
        .background {
            ZStack(alignment: .center) {
                Color.clear
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "cup.and.heat.waves.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.quaternary)
                    
                    Text("DietiDeals24")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.quaternary)
                    
                    Text("INGSW2324_63")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.quaternary)
                    
                    HStack(alignment: .top) {
                        VStack{
                            Text("Oreste Leone\nN86001980")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.quaternary)
                        }
                        VStack{
                            Text("Giuseppe Falso\nN86002941")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.quaternary)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                    
                }
                
            }
        }
        .task {
            await viewModel.getUserData()
        }
        .scrollBounceBehavior(.basedOnSize)
        .animation(.easeInOut, value: viewModel.userDataModel)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(Text("Personal Area"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button(role: .destructive){
                        self.viewModel.logout()
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
        .overlay {
            self.loaderView()
        }
    }
}


#Preview {
    NavigationStack{
        UserAreaMainView(viewModel: .init(coordinator: .init(appContainer: .init()), vendorService: DefaultVendorService(rest: DefaultRESTDataSource()), auctionService: DefaultAuctionService(rest: DefaultRESTDataSource())))
    }
}
