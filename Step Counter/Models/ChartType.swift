//
//  ChartType.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import SwiftUI

/// Each case provides presentation metadata (title, symbol, subtitle and
/// accessibility label) and any associated values needed to format them.
///
/// Cases
/// - `stepBar(average:)` — Daily steps bar chart; uses `average` for subtitles.
/// - `stepWeekdayPie` — Average steps by weekday (summary).
/// - `weightLine(average:)` — Weight history line chart; `average` formatted to 1 decimal.
/// - `weightDiffBar` — Average weight change per weekday.
///
/// SeeAlso: `HealthMetricContext` — maps chart types to their health metric (steps/weight).
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
            String(localized: "Steps")
        case .stepWeekdayPie:
            String(localized: "Averages")
        case .weightLine:
            String(localized: "Weight")
        case .weightDiffBar:
            String(localized: "Average Weight Change")
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
        case let .stepBar(average):
            String(localized: "Avg: \(average.formatted()) steps")
        case .stepWeekdayPie:
            String(localized: "Last 28 Days")
        case let .weightLine(average):
            String(localized: "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs")
        case .weightDiffBar:
            String(localized: "Per Weekday (Last 28 Days)")
        }
    }

    var accessabilityLabel: String {
        switch self {
        case let .stepBar(average):
            String(localized: "Bar chart, step count, last 28 days, average steps per day: \(average.formatted())")

        case .stepWeekdayPie:
            String(localized: "Pie chart, average steps per weekday")

        case let .weightLine(average):
            String(
                localized: "Line chart, weight, average weight: \(average.formatted(.number.precision(.fractionLength(1)))) pounds,  goal weight: 155 pounds"
            )

        case .weightDiffBar:
            String(localized: "Bar chart, average weight difference per weekday")
        }
    }
}
