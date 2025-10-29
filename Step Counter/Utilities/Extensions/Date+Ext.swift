//
//  Date+Ext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

extension Date {
    /// Weekday as integer (1 = Sunday, 2 = Monday, ..., 7 = Saturday).
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// Full weekday name in user's locale (e.g., "Friday").
    var weekdayTitle: String {
        formatted(.dateTime.weekday(.wide))
    }

    /// Accessibility-friendly date string showing month and day (e.g., "October 24").
    var accessibilityDate: String {
        formatted(.dateTime.month(.wide).day())
    }

    func createDateInterval(daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: self)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        return DateInterval(start: startDate, end: endDate)
    }
}
