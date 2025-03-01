//
//  ExploreMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/26/25.
//
import SwiftUI

public struct ExploreMainView: View, LoadableView {
    
    @State var viewModel: ExploreMainViewModel
    
    init(viewModel: ExploreMainViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            switch viewModel.state {
                case .explore:
                    exploreView()
                        .task {
                            if viewModel.exploreItems.isEmpty {
                                viewModel.getMoreExploreItems()
                            }
                        }
                case .loading:
                    loaderView()
                        .onTapGesture {
                            viewModel.isSearching = false
                            viewModel.searchText = ""
                            viewModel.state = .explore
                        }
                case .searching:
                    auctionListViewWithFilters()
            }
        }
        .searchable(text: self.$viewModel.searchText , isPresented: $viewModel.isSearching, placement: .navigationBarDrawer(displayMode: viewModel.state == .searching ? .always : .automatic), prompt: "Search for products or services")
        .onChange(of: viewModel.searchText) { old, newValue in
            viewModel.isLoading = !newValue.isEmpty
            viewModel.state = newValue.isEmpty ? .explore : .loading
        }
        .onSubmit(of: .search) {
            viewModel.makeSearchRequest()
        }
        .navigationTitle("Explore")
    }
    
    
}

extension ExploreMainView {
    
    @ViewBuilder
    func auctionListViewWithFilters() -> some View {
        VStack {
            filterScrollView()
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            AuctionListView(auctionList: viewModel.searchItems, additionalInfo: viewModel.searchItems.count.formatted(), onTapCallBack: viewModel.getAuctionDetail, shouldFetchMore: viewModel.shouldFetchMoreSearchItem, fetchCallBack: viewModel.getSearchResults)
                .scrollIndicatorsFlash(onAppear: true)
                .padding(.top)
        }
    }
    
    @ViewBuilder
    func filterScrollView() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 8) {
                ForEach(viewModel.filteringOptions, id: \.self) { filterOption in
                    let isSet = viewModel.isFilterSet(for: filterOption)
                    Button {
                        print("showModalForFilter: \(filterOption)")
                        viewModel.openFilterSheet(for: filterOption)
                    } label: {
                        Text(filterOption.title)
                    }
                    .buttonStyle(TagButtonStyle(isActive: isSet))
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    func exploreView() -> some View {
        AuctionListView(auctionList: viewModel.exploreItems, mainHeader: "Latest Auctions", additionalInfo: viewModel.exploreItems.count.formatted(), onTapCallBack: viewModel.getAuctionDetail, shouldFetchMore: viewModel.shouldFetchMoreExploreItem, fetchCallBack: viewModel.getMoreExploreItems)
            .scrollIndicatorsFlash(onAppear: true)
            .padding(.top)
    }
}

#Preview {
    @Previewable @State var exploreMainViewModel =  ExploreMainViewModel(coordinator: .init(appContainer: .init()))
    exploreMainViewModel.exploreItems = AuctionCardModel.mockData
    
    return NavigationStack {
        ExploreMainView(viewModel: exploreMainViewModel)
    }
}
