//
//  RadioButtonRow.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/27/25.
//
import SwiftUI

struct RadioButtonRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .accent : .primary)
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#Preview {
    RadioButtonRow(title: "Test", isSelected: true, action: { })
        .padding()
}
