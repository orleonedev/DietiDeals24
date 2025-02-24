//
//  TagButton.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//

import SwiftUI

struct TagButtonStyle: ButtonStyle {
    
    var isActive: Bool = false
    
    init(isActive: Bool) {
        self.isActive = isActive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(12)
            .padding(.horizontal, 4)
            .background(isActive ? Color.accentColor.opacity(0.4) : Color.clear)
            .background{
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.accentColor : .secondary, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
