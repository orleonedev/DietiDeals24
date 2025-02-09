//
//  TextFieldRoundedCornerStyleClear.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/9/25.
//

import SwiftUI

struct TextFieldRoundedCornerStyleClear: TextFieldStyle {
    @FocusState private var isFocused: Bool // Track focus state
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12) // Add padding inside the TextField
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.accentColor : .secondary, lineWidth: 1) // Change border color when focused
            )
            .foregroundColor(.primary) // Text color
            .font(.body) // Set the font
            .focused($isFocused) // Bind the focus state
    }
}
