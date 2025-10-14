//
//  ChartDataTypes.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

struct WeekdayChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
