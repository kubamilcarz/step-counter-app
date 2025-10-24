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
        self.formatted(.dateTime.weekday(.wide))
    }
    
    /// Accessibility-friendly date string showing month and day (e.g., "October 24").
    var accessibilityDate: String {
        self.formatted(.dateTime.month(.wide).day())
    }
}
