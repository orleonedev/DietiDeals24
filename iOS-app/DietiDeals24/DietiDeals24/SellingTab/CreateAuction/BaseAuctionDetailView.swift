//
//  BaseAuctionDetailView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//
import SwiftUI
import PhotosUI

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
            ValidableTextField(validationError: $viewModel.validationTitleError, text: $viewModel.baseAuction.title, validation: viewModel.validateTitle, label: "Title".localized)
                .focused(self.$isFocused)

            
            ValidableTextField(validationError: $viewModel.validationDescriptionError, text: $viewModel.baseAuction.description, validation: viewModel.validateDescription, label: "Description".localized)
                .focused(self.$isFocused)

            
            MenuPicker(title: "Category".localized, selection: $viewModel.baseAuction.category, options: Array(AuctionCategory.allCases.dropFirst()), placeholderLabel: "Select a category".localized)
            
        }
        .padding(.vertical)
    }
    
    @ViewBuilder @MainActor
    func imagesContainerView() -> some View {
        VStack(alignment: .leading, spacing: 4){
            HStack{
                Text("Images (optional)")
                    .font(.caption)
                    .padding(.horizontal, 4)
                Spacer()
                Text("\(viewModel.imagesPreviewState.count)/6")
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
            
            ScrollView(.horizontal) {
                if viewModel.imagesPreviewState.isEmpty {
                    PhotosPicker(selection: $viewModel.imagesPickerSelection, maxSelectionCount: 6, selectionBehavior: .default, matching: .images, preferredItemEncoding: .automatic, photoLibrary: .shared()) {
                        VStack(alignment: .center, spacing: 0){
                            Image(systemName: "photo.stack")
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
                    .photosPickerStyle(.presentation)
                    .ignoresSafeArea()
                } else {
                    HStack(spacing: 24) {
                        ForEach(viewModel.imagesPreviewState, id: \.self) { preview in
                            GeometryReader { proxy in
                                AuctionPreviewImage(state: preview)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .background(.quaternary)
                                    .clipped()
                                    .clipShape(.rect(cornerRadius: 12))
                            }
                            .aspectRatio(1.77, contentMode: .fit)
                        }
                        
                        PhotosPicker(selection: $viewModel.imagesPickerSelection, maxSelectionCount: 6, selectionBehavior: .default, matching: .images, preferredItemEncoding: .automatic, photoLibrary: .shared()) {
                                    Image(systemName: "photo.stack")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .padding()
                                        .foregroundStyle(.accent)
                                
                            }
                        .photosPickerStyle(.presentation)
                        .ignoresSafeArea()
                        
                        
                    }
                    .padding()
                }
            }
            .defaultScrollAnchor(viewModel.imagesPreviewState.isEmpty ? .center : .leading)
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
