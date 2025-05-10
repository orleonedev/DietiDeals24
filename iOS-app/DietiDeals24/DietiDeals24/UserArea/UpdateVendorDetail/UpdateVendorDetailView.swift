//
//  BecomeAVendorView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

struct UpdateVendorDetailView: View, LoadableView {
    
    @State var viewModel: UpdateVendorDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32){
                headingDisclaimer()
                FormContent()
                submitUpdateVendorDetailButton()
            }
            .padding()
        }
        .interactiveDismissDisabled()
        .navigationTitle(Text("Update Your Profile"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.dismiss()
                }
            }
        }
        .overlay {
            loaderView()
        }
    }
}

extension UpdateVendorDetailView {
    
    @ViewBuilder
    func headingDisclaimer() -> some View {
        Text("We Would love to hear more about you, to enrich the experience for all our users!")
            .font(.body)
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .foregroundColor(.primary)
            .padding(.vertical)
    }
    
    @ViewBuilder
    func FormContent() -> some View {
        VStack(alignment: .leading, spacing: 21 ){
            RoundedCornerTextField(text: $viewModel.shortBio, label: "Short Bio".localized)
                
            RoundedCornerTextField(text: $viewModel.geoLocation, label: "Geographical Location".localized)
                .textContentType(.addressCity)
                
            RoundedCornerTextField(text: $viewModel.url, label: "Website".localized)
                .textContentType(.URL)
                .keyboardType(.URL)
            
        }
        
    }
    
    @ViewBuilder
    func submitUpdateVendorDetailButton() -> some View {
        VStack {
            Button(action: {
                viewModel.submitUpdateVendorDetail()
            }) {
                Text("Update Vendor Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.accent)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    UpdateVendorDetailView(viewModel: .init(userAreaCoordinator: .init(appContainer: .init()), vendorService: DefaultVendorService(rest: DefaultRESTDataSource())))
}
