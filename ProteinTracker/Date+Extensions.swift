//
//  Date+Extensions.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/03.
//

import Foundation

extension Date {
    func formattedRelativeString() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            formatter.dateFormat = "HH:mm" // e.g., "15:30"
            return "Today, \(formatter.string(from: self))" // e.g., "15:30, Today"
        } else if calendar.isDateInYesterday(self) {
            formatter.dateFormat = "hh:mm"
            return "Yestoday, \(formatter.string(from: self))" // e.g., "15:30, Yesterday"
        } else {
            formatter.dateFormat = "MMM d, HH:mm"
            return formatter.string(from: self) // e.g., "Jul 28, 15:30"
        }
    }
}
