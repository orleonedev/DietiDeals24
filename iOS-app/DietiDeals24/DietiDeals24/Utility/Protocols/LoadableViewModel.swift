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
            .ignoresSafeArea()
            .transition(.opacity)
        }
    }
}
