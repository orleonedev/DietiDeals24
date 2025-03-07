//
//  ValidableTextField.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/9/25.
//

import SwiftUI

struct ValidableTextField: View {
    
    @FocusState private var isFocused: Bool // Track focus state
    @Binding var validationError: Bool
    @Binding var text: String
    var validation: () -> Void
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
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor(), lineWidth: 1) // Change border color when focused
                )
                .foregroundColor(.primary) // Text color
                .font(.body) // Set the font
                .focused($isFocused) // Bind the focus state
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        validation()
                    } else {
                        validationError = false
                    }
                }
                .onSubmit(of: .text, validation)
            
        }
    }
    
    func strokeColor() -> Color {
        guard validationError else {
            return /*isFocused ? Color.accentColor :*/ .secondary
        }
        return .red
    }
    
    func labelColor() -> Color {
        guard validationError else {
            return /*isFocused ? Color.accentColor :*/ .primary
        }
        return .red
    }
}

struct SecureValidableTextField: View {
    
    @FocusState private var isFocused: Bool // Track focus state
    @Binding var validationError: Bool
    @Binding var text: String
    var validation: () -> Void

    var label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text(label)
                .font(.caption)
                .padding(.horizontal, 4)
                .animation(.easeInOut) { view in
                    view.foregroundStyle(labelColor())
                }
            SecureField(label, text: $text)
                .textFieldStyle(.plain)
                .padding(12) // Add padding inside the TextField
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor(), lineWidth: 1) // Change border color when focused
                )
                .foregroundColor(.primary) // Text color
                .font(.body) // Set the font
                .focused($isFocused) // Bind the focus state
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        validation()
                    } else {
                        validationError = false
                    }
                }
                .onSubmit(of: .text, validation)
        }
    }
    
    func strokeColor() -> Color {
        guard validationError else {
            return isFocused ? Color.accentColor : .secondary
        }
        return .red
    }
    
    func labelColor() -> Color {
        guard validationError else {
            return isFocused ? Color.accentColor : .primary
        }
        return .red
    }
}
