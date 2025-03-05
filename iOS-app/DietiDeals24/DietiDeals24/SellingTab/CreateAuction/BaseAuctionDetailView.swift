//
//  BaseAuctionDetailView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//
import SwiftUI

struct BaseAuctionDetailView: View, LoadableView {
    
    @State var viewModel: BaseAuctionDetailViewModel
    @FocusState var isFocused: Bool
    
    public var body: some View {
        VStack(spacing: 0){
            ProgressView(value: 1, total: 4)
            ScrollView {
                VStack(spacing: 32) {
                    formFields()
                    imagesContainerView()
                    nextButton()
                }
                .padding()
            }
            .onTapGesture {
                self.isFocused = false
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .interactiveDismissDisabled(true)
        .navigationTitle("Create Auction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Cancel") {
                    self.viewModel.tryToDismiss()
                }
            }
        }
    }
}


extension BaseAuctionDetailView {
    
    @ViewBuilder
    func formFields() -> some View {
        VStack(alignment: .leading, spacing: 32 ){
            ValidableTextField(validationError: $viewModel.validationTitleError, text: $viewModel.baseAuction.title, validation: viewModel.validateTitle, label: "Title")
                .focused(self.$isFocused)

            
            ValidableTextField(validationError: $viewModel.validationDescriptionError, text: $viewModel.baseAuction.description, validation: viewModel.validateDescription, label: "Description")
                .focused(self.$isFocused)

            
            MenuPicker(title: "Category", selection: $viewModel.baseAuction.category, options: Array(AuctionCategory.allCases.dropFirst()), placeholderLabel: "Select a category")
            
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    func imagesContainerView() -> some View {
        VStack(alignment: .leading, spacing: 4){
            HStack{
                Text("Images (optional)")
                    .font(.caption)
                    .padding(.horizontal, 4)
                Spacer()
                Text("\(viewModel.baseAuction.images.count)/6")
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
            
            ScrollView(.horizontal) {
                if viewModel.baseAuction.images.isEmpty {
                    Button(action: {
                        
                    }) {
                        VStack(alignment: .center, spacing: 0){
                            Image(systemName: "photo.badge.plus.fill")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .foregroundStyle(.accent)
                            
                            Text("Add up to 6 images")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .padding()
                    }
                } else {
                    HStack(spacing: 24) {
                        ForEach(viewModel.baseAuction.images, id: \.self) { image in
                            GeometryReader { proxy in
                                RemoteImage(urlString: image)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .clipped()
                                    .clipShape(.rect(cornerRadius: 12))
                            }
                            .aspectRatio(1.77, contentMode: .fit)
                        }
                        
                        if viewModel.baseAuction.images.count < 6 {
                            Button(action: {
                                
                            }) {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .padding()
                                    .scaledToFit()
                                    .foregroundStyle(.accent)
                            }
                            .padding()
                        }
                        
                    }
                    .padding()
                }
                
                
            }
            .scrollBounceBehavior(.basedOnSize)
            .defaultScrollAnchor(viewModel.baseAuction.images.isEmpty ? .center : .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.secondary, lineWidth:1)
            )
            .frame(height: 200)
            
        }
    }
    
    @ViewBuilder
    func nextButton() -> some View {
        Button(action: {
            self.viewModel.goToAuctionDetails()
        }) {
            Text("Next")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.accent)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

#Preview {
    NavigationStack {
        BaseAuctionDetailView(viewModel: .init(sellingCoordinator: .init(appContainer: .init())))
    }
}
