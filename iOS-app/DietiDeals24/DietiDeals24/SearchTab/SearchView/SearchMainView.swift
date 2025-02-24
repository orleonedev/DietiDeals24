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
                case .loading:
                    loaderView()
                case .idle:
                    categoryListView()
                case .fetched:
                    auctionListView()
            }
            
        }
        .searchable(text: self.$viewModel.searchText , placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for products or services")
        .onChange(of: viewModel.searchText) { old, newValue in
            viewModel.isLoading = !newValue.isEmpty
            viewModel.viewState = newValue.isEmpty ? .idle : .loading
        }
        .onSubmit(of: .search) {
            viewModel.getSearchResults()
        }
    }
    
}

extension SearchMainView {
    
    @ViewBuilder
    func auctionListView() -> some View {
        VStack {
            filterScrollView()
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            ScrollView {
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, alignment: .center ,spacing: 32) {
                    ForEach(viewModel.fetchedSearchResults, id: \.id) { auction in
                        AuctionCardView(auction: auction)
                    }
                }
                
            }
            .padding(.horizontal)
            .scrollIndicatorsFlash(onAppear: true)
        }
    }
    
    @ViewBuilder
    func categoryListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.filterModel.categoryTypes, id: \.self) { category in
                    Button {
                        
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
                    } label: {
                        Text(filterOption.title)
                    }
                    .buttonStyle(TagButtonStyle(isActive: isSet))
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
        .padding(.vertical)
    }
    
}

#Preview {
    NavigationStack{
        SearchMainView(viewModel: .init(coordinator: .init(appContainer: .init())))
        
    }
    
}
