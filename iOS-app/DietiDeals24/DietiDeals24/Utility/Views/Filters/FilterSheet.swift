//
//  FilterSheet.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/27/25.
//

import SwiftUI

struct FilterSelectionSheet<Option: FilterModelProtocol>: View {
    let title: String
    let options: [Option]
    @State var selectedOption: Option
    let onSelect: (Option) -> Void
    let onCancel: () -> Void

    var body: some View {
        List {
//            RadioButtonRow(title: "All", isSelected: selectedOption == options.first) {
//                selectedOption = nil
//            }
            ForEach(options) { option in
                RadioButtonRow(title: option.description, isSelected: selectedOption == option) {
                    selectedOption = option
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    onCancel()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Apply") {
                    onSelect(selectedOption)
                }
            }
            
        }
        .presentationDetents([.medium])
        
    }
}

#Preview {
    @Previewable @State var selectedOption: AuctionType = .all
    @Previewable @State var isPresented: Bool = true
    VStack {
        Button("Show Sheet") {
            isPresented.toggle()
        }
        SearchMainView(viewModel: .init(coordinator: .init(appContainer: .init())))
            .sheet(isPresented: $isPresented) {
                NavigationStack{
                    FilterSelectionSheet(title: "Test", options: AuctionType.allCases, selectedOption: selectedOption) { option in
                        selectedOption = option
                        isPresented.toggle()} onCancel: { isPresented.toggle()
                        }
                }
            }
    }
    
}

