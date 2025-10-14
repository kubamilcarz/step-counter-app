//
//  Date+ext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
