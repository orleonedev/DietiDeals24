//
//  SearchMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import SwiftUI

struct SearchMainView: View, LoadableView {
    
    @State var viewModel: SearchMainViewModel
    var body: some View {
        VStack{
            switch viewModel.viewState {
                case .idle:
                    categoryListView()
                case .fetched:
                    auctionListViewWithFilters()
            }
        }
        .searchable(text: self.$viewModel.searchText , isPresented: $viewModel.isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for products or services")
        .onSubmit(of: .search) {
            viewModel.makeSearchRequest()
        }
        .onChange(of: viewModel.isSearching, initial: false, { oldValue, newValue in
            if oldValue == true && newValue == false {
                viewModel.viewState = .idle
            }
        })
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Search")
        .overlay {
            loaderView()
        }
    }
    
}

extension SearchMainView {
    
    @ViewBuilder
    func auctionListViewWithFilters() -> some View {
        VStack {
            filterScrollView()
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            AuctionListView(auctionList: viewModel.fetchedSearchResults, additionalInfo: viewModel.fetchedSearchResults.count > 0 ? viewModel.fetchedSearchResults.count.formatted() : "", onTapCallBack: viewModel.getAuctionDetail, shouldFetchMore: viewModel.shouldFetchMoreSearchItem, fetchCallBack: viewModel.getSearchResults)
            .scrollIndicatorsFlash(onAppear: true)
        }
        .overlay {
            if viewModel.fetchedSearchResults.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
    
    @ViewBuilder
    func categoryListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(AuctionCategory.allCases, id: \.self) { category in
                    Button {
                        viewModel.setFilter(for: .category, value: category)
                        viewModel.makeSearchRequest(preserveFilters: true)
                    } label: {
                        VStack(alignment: .leading){
                            HStack{
                                Text(category.label)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.trailing)
                            }
                            .padding()
                            Divider()
                        }
                        .padding(.horizontal)
                    }
                }
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
    
}

#Preview {
    NavigationStack{
        SearchMainView(viewModel: .init(coordinator: .init(appContainer: .init()), auctionService: DefaultAuctionService(rest: DefaultRESTDataSource())))
        
    }
    
}
