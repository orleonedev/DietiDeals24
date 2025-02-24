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
            filterScrollView()
                .fixedSize(horizontal: false, vertical: true)
            
            ScrollView {
                LazyVStack (spacing: 8){
                    ForEach(0...200, id: \.self) { val in
                        Text("Item \(val)")
                    }
                }
            }
            .scrollIndicatorsFlash(onAppear: true)
        }
        .searchable(text: self.$viewModel.searchText , placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for products or services")
    }
    
}

extension SearchMainView {
    
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
