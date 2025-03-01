//
//  MenuPicker.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//

import SwiftUI

struct MenuPicker<T: Hashable>: View where T: CustomStringConvertible{
    
    let title: String
    @Binding var selection: T?
    let options: [T]
    let placeholderLabel: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4){
            Text(title)
                .font(.caption)
                .padding(.horizontal, 4)
            
            Picker(title, selection: $selection, content: {
                Text(placeholderLabel)
                    .tag(placeholderLabel as? T, includeOptional: true)
                ForEach(options, id: \.self) { option in
                    Text(option.description)
                        .tag(option)
                }
            }, currentValueLabel: {
                Text((selection?.description) ?? placeholderLabel)
            })
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 1)
                }
                .tint(selection != nil ? .accentColor : .secondary)
            
        }
    }
}


#Preview {
    @Previewable @State var selection: AuctionCategory?
    
    MenuPicker(title: "Test", selection: $selection, options: Array(AuctionCategory.allCases.dropFirst()), placeholderLabel: "Select a category")
}
