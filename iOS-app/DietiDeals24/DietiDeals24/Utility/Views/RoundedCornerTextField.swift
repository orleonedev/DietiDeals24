//
//  RoundedCornerTextField.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/1/25.
//
import SwiftUI

struct RoundedCornerTextField: View {
    
    @FocusState private var isFocused: Bool // Track focus state
    @Binding var text: String
    var label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text(label)
                .font(.caption)
                .padding(.horizontal, 4)
                .animation(.easeInOut) { view in
                    view.foregroundStyle(labelColor())
                }
            TextField(label, text: $text)
                .textFieldStyle(TextFieldRoundedCornerStyleClear())
                .focused($isFocused)
            
        }
    }
    
    func strokeColor() -> Color {
        return isFocused ? Color.accentColor : .secondary
    }
    
    func labelColor() -> Color {
        return isFocused ? Color.accentColor : .primary
    }
}

