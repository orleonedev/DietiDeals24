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
                case .searching:
                    auctionListViewWithFilters()
            }
        }
        .searchable(text: self.$viewModel.searchText , isPresented: $viewModel.isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for products or services")
        .onSubmit(of: .search) {
            viewModel.makeSearchRequest()
        }
        .onChange(of: viewModel.isSearching, initial: false, { oldValue, newValue in
            if oldValue == true && newValue == false {
                viewModel.state = .explore
            }
        })
        .navigationTitle("Explore")
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            loaderView()
        }
    }
    
    
}

extension ExploreMainView {
    
    @ViewBuilder
    func auctionListViewWithFilters() -> some View {
        VStack {
            filterScrollView()
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            AuctionListView(auctionList: viewModel.searchItems, additionalInfo: viewModel.searchItems.count > 0 ? viewModel.searchItems.count.formatted() : "", onTapCallBack: viewModel.getAuctionDetail, shouldFetchMore: viewModel.shouldFetchMoreSearchItem, fetchCallBack: viewModel.getSearchResults)
                .scrollIndicatorsFlash(onAppear: true)
        }
        .overlay {
            if viewModel.searchItems.isEmpty {
                ContentUnavailableView.search
            }
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
        
        AuctionListView(auctionList: viewModel.exploreItems, mainHeader: viewModel.exploreItems.count > 0 ? "Latest Auctions" : "", additionalInfo: viewModel.exploreItems.count > 0 ? viewModel.exploreItems.count.formatted() : "", onTapCallBack: viewModel.getAuctionDetail, shouldFetchMore: viewModel.shouldFetchMoreExploreItem, fetchCallBack: viewModel.getMoreExploreItems)
            .scrollIndicatorsFlash(onAppear: true)
            .overlay {
                if viewModel.exploreItems.isEmpty && !viewModel.isFetchingExploreItems {
                    ContentUnavailableView("Something went wrong", systemImage: "questionmark.circle.dashed", description: Text("We couldn't find any auctions at this time. Try again later.")
                    )
                }
            }
    }
}

#Preview {
    @Previewable @State var exploreMainViewModel =  ExploreMainViewModel(coordinator: .init(appContainer: .init()), auctionService: DefaultAuctionService(rest: DefaultRESTDataSource()))
    //exploreMainViewModel.exploreItems = AuctionCardModel.mockData
    
    NavigationStack {
        ExploreMainView(viewModel: exploreMainViewModel)
    }
}
