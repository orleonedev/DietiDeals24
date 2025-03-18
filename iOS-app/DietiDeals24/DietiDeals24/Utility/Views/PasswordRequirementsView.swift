//
//  PasswordRequirementsView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/15/25.
//

import SwiftUI

public struct PasswordRequirementsView: View {
    
    let requirements: [String]
    
    public var body: some View {
       
        VStack(alignment: .leading) {
            ForEach(requirements, id: \.self) { requirement in
                self.requirementView(requirement)
            }
        }
    }
    
    
    
    @ViewBuilder
    private func requirementView(_ text: String) -> some View {
            HStack {
                Image(systemName: "circle.fill")
                    .scaleEffect(0.6)
                    .foregroundStyle(.quaternary)
                Text(text)
                    .foregroundStyle(.secondary)
            }
            
        }
}

#Preview {
    PasswordRequirementsView(requirements: ["At least one uppercase letter", "At least one lowercase letter", "At least one digit", "At least one special character", "Minimum length of 8 characters"])
}
