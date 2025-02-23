//
//  ValidableDatePicker.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/19/25.
//

import SwiftUI

struct ValidableDatePicker: View {
    
    @Binding var validationError: Bool
    @Binding var date: Date
    var validation: () -> Void
    var label: String
    var range: ClosedRange<Date>
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text(label)
                .font(.caption)
                .padding(.horizontal, 4)
                .animation(.easeInOut) { view in
                    view.foregroundStyle(labelColor())
                }
            
            DatePicker("",selection: $date,
                       in: range,
                       displayedComponents: .date)
            .datePickerStyle(.compact)
            .labelsHidden()
            .onChange(of: date) { _, _ in
                validation()
            }
        }
    }
    
    func labelColor() -> Color {
        return validationError ? .red : .primary
    }
}

#Preview {
    @Previewable @State var validationError: Bool = false
    @Previewable @State var date: Date = .now
    ValidableDatePicker(validationError: $validationError, date: $date, validation: {validationError = true}, label: "Label", range: .init(uncheckedBounds: (lower: .distantPast, upper: .now)))
}
