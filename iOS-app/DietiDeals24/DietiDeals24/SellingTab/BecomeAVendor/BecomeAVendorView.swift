//
//  BecomeAVendorView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

struct BecomeAVendorView: View, LoadableView {
    
    @State var viewModel: BecomeAVendorViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32){
                headingDisclaimer()
                FormContent()
                submitVendorDetailButton()
            }
            .padding()
        }
        .interactiveDismissDisabled()
        .navigationTitle(Text("Become a Vendor"))
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

extension BecomeAVendorView {
    
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
            RoundedCornerTextField(text: $viewModel.shortBio, label: "Short Bio")
                
            RoundedCornerTextField(text: $viewModel.geoLocation, label: "Geographical Location")
                .textContentType(.addressCity)
                
            RoundedCornerTextField(text: $viewModel.url, label: "Link to your website")
                .textContentType(.URL)
                .keyboardType(.URL)
            
        }
        
    }
    
    @ViewBuilder
    func submitVendorDetailButton() -> some View {
        VStack {
            Button(action: {
                viewModel.submitVendorDetail()
            }) {
                Text("Submit Vendor Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.accent)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal)
#if DEV && DEBUG
            Button("Skip Submit") {
                Task{
                    do {
                        viewModel.skipSubmitVendorDetail()
                    } catch {
                        print(error)
                    }
                }
            }
            .padding()
#endif
        }
    }
}

#Preview {
    BecomeAVendorView(viewModel: .init(sellingCoordinator: .init(appContainer: .init()), vendorService: DefaultVendorService(rest: DefaultRESTDataSource())))
}
