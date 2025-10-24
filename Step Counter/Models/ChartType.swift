//
//  ChartType.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
    
    var isNav: Bool {
        switch self {
        case .stepBar, .weightLine:
            true
        case .stepWeekdayPie, .weightDiffBar:
            false
        }
    }
    
    var context: HealthMetricContext {
        switch self {
        case .stepBar, .stepWeekdayPie:
            .steps
        case .weightDiffBar, .weightLine:
            .weight
        }
    }
    
    var title: String {
        switch self {
        case .stepBar:
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine:
            "Weight"
        case .weightDiffBar:
            "Average Weight Change"
        }
    }
    
    var symbol: String {
        switch self {
        case .stepBar:
            "figure.walk"
        case .stepWeekdayPie:
            "calendar"
        case .weightLine, .weightDiffBar:
            "figure"
        }
    }
    
    var subtitle: String {
        switch self {
        case .stepBar(let average):
            "Avg: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 Days"
        case .weightLine(let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 Days)"
        }
    }
    
    var accessabilityLabel: String {
        switch self {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average.formatted())"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine(let average):
            "Line chart, weight, average weight: \(average.formatted(.number.precision(.fractionLength(1)))) pounds,  goal weight: 155 pounds"
        case .weightDiffBar:
            "Bar chart, average weight difference per weekday"
        }
    }
}
