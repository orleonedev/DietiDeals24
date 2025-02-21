//
//  Date+.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/21/25.
//

import Foundation

extension Date {
    
    func formattedString(_ format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
