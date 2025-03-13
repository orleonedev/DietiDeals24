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
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func calculateTimeDifferenceFromNowUTC() -> TimeInterval {
        let now = Date.now
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let dateComponents = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        let nowUTC = utcCalendar.date(from: dateComponents)!
        let refereceDateComponents = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        let referenceUTC = utcCalendar.date(from: refereceDateComponents)!
        let nowSeconds = nowUTC.timeIntervalSince1970
        let endTimeSeconds = referenceUTC.timeIntervalSince1970

        return endTimeSeconds - nowSeconds
    }
}
