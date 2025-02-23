//
//  LoadableViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI

protocol LoadableViewModel {
    var isLoading: Bool { get set }
}

protocol LoadableView: View {
    associatedtype ViewModel: LoadableViewModel
    var viewModel: ViewModel { get set }
}

extension View where Self: LoadableView {
    @ViewBuilder
    func loaderView() -> some View {
        if viewModel.isLoading {
            ZStack(alignment: .center) {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(3.5)
                        .tint(.accent)
                }
                
            }
            .transition(.opacity)
        }
    }
}

@Observable
class testViewModel: LoadableViewModel {
    var isLoading: Bool = false
}

struct test: View, LoadableView {
    @State var viewModel: testViewModel = testViewModel()
    
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            Button("load") {
                self.viewModel.isLoading = true
            }
        }
        .overlay {
            if viewModel.isLoading {
                self.loaderView()
            }
        }
    }
}

#Preview {
    test()
}
