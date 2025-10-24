//
//  ChartHelper.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import Algorithms
import Foundation

/// A utility struct providing static methods for processing and transforming health data for chart visualization.
///
/// `ChartHelper` serves as a central location for all chart-related data transformations,
/// including conversions, calculations, and aggregations. These methods ensure consistent
/// data processing across all chart components in the app.
///
/// ## Key Capabilities
/// - Converting between data models (`HealthMetric` ↔ `DateValueChartData`)
/// - Calculating statistical aggregates (averages, totals)
/// - Grouping data by time periods (weekdays)
/// - Processing weight differentials and trends
/// - Parsing user-selected chart data
///
/// ## Dependencies
/// - **Swift Algorithms**: Used for advanced data chunking operations
///
/// - Note: All methods are static; this struct is not meant to be instantiated.
/// - SeeAlso: `DateValueChartData`, `HealthMetric`
struct ChartHelper {
    
    // MARK: - Data Conversion
    
    /// Converts an array of `HealthMetric` objects to `DateValueChartData` for chart rendering.
    ///
    /// This is the primary conversion method used throughout the app to transform raw health
    /// data from HealthKit into a format optimized for SwiftUI Charts. The conversion is
    /// straightforward: each `HealthMetric` becomes a `DateValueChartData` with the same
    /// date and value properties.
    ///
    /// ## Transformation Process
    /// ```
    /// HealthMetric(date: Oct 24, value: 8542)
    ///     ↓
    /// DateValueChartData(id: UUID(), date: Oct 24, value: 8542)
    /// ```
    ///
    /// - Parameter data: An array of `HealthMetric` objects from HealthKit queries.
    /// - Returns: An array of `DateValueChartData` objects ready for chart visualization.
    ///
    /// ## Usage Example
    /// ```swift
    /// let healthMetrics = try await healthManager.fetchStepCount()
    /// let chartData = ChartHelper.convert(data: healthMetrics)
    /// // Now use chartData in SwiftUI Charts
    /// ```
    ///
    /// - Note: The returned array maintains the same order as the input array.
    /// - Important: Each converted item receives a new unique UUID identifier.
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value) }
    }
    
    // MARK: - Statistical Calculations
    
    /// Calculates the arithmetic mean (average) of all values in the dataset.
    ///
    /// This method computes the average value across all data points, which is useful for:
    /// - Displaying "average steps per day" labels
    /// - Showing baseline comparison lines in charts
    /// - Calculating overall performance metrics
    ///
    /// ## Calculation Method
    /// ```
    /// Average = (Sum of all values) / (Count of data points)
    /// ```
    ///
    /// ### Example
    /// Given data points with values `[100, 200, 300]`:
    /// - Sum = 600
    /// - Count = 3
    /// - Average = 600 / 3 = 200.0
    ///
    /// - Parameter data: An array of chart data points to average.
    /// - Returns: The average value as a `Double`. Returns `0` if the array is empty.
    ///
    /// - Note: Empty arrays are safely handled by returning 0 instead of causing division errors.
    /// - Important: The result is not rounded; use number formatters for display purposes.
    static func averageValue(for data: [DateValueChartData]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.value }
        return total/Double(data.count)
    }
    
    // MARK: - Chart Interaction
    
    /// Finds and returns the data point corresponding to a user-selected date in a chart.
    ///
    /// This method is used for chart interactivity, allowing users to tap or hover over
    /// a chart to see specific data for a selected date. It performs a day-level comparison
    /// to find the matching data point, ignoring time components.
    ///
    /// ## Matching Logic
    /// Uses `Calendar.current.isDate(_:inSameDayAs:)` to compare dates, which means:
    /// - Compares year, month, and day only
    /// - Ignores hours, minutes, seconds
    /// - Accounts for the user's current calendar system
    ///
    /// ### Example
    /// ```swift
    /// // User taps on October 24 in the chart
    /// let selected = ChartHelper.parseSelectedData(
    ///     from: chartData,
    ///     in: selectedDate
    /// )
    /// // Returns: DateValueChartData for Oct 24 (if it exists)
    /// ```
    ///
    /// - Parameters:
    ///   - data: The complete array of chart data to search within.
    ///   - selectedDate: The date selected by the user, or `nil` if no selection exists.
    /// - Returns: The matching `DateValueChartData` if found, or `nil` if:
    ///   - No date is selected (`selectedDate` is `nil`)
    ///   - No matching data point exists for the selected date
    ///
    /// - Note: Returns the **first** matching data point. Ensure data doesn't have duplicate dates.
    /// - SeeAlso: Used in conjunction with SwiftUI Charts' `.chartAngleSelection()` and `.chartXSelection()` modifiers.
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        
        return data.first(where: {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        })
    }
    
    // MARK: - Weekday Aggregation
    
    /// Calculates the average value for each weekday across all weeks in the dataset.
    ///
    /// This method groups health metrics by weekday (Monday, Tuesday, etc.) and computes
    /// the average value for each day of the week. This is particularly useful for:
    /// - Identifying weekly patterns (e.g., "I walk more on weekends")
    /// - Creating weekday comparison charts (pie charts, bar charts)
    /// - Understanding behavioral trends across the week
    ///
    /// ## Process Flow
    /// 1. **Sort**: Orders all metrics by weekday (Monday=1, Tuesday=2, ..., Sunday=7)
    /// 2. **Chunk**: Groups consecutive metrics with the same weekday together
    /// 3. **Calculate**: For each weekday group:
    ///    - Sums all values for that weekday
    ///    - Divides by count to get average
    /// 4. **Create**: Returns one `DateValueChartData` per weekday with the average value
    ///
    /// ### Example Input/Output
    /// **Input**: 14 days of step data (2 weeks)
    /// ```
    /// Mon Oct 13: 8,000 steps
    /// Tue Oct 14: 6,000 steps
    /// Mon Oct 20: 10,000 steps
    /// Tue Oct 21: 8,000 steps
    /// ...
    /// ```
    ///
    /// **Output**: 7 data points (one per weekday)
    /// ```
    /// Monday: 9,000 steps (average of 8,000 and 10,000)
    /// Tuesday: 7,000 steps (average of 6,000 and 8,000)
    /// ...
    /// ```
    ///
    /// - Parameter metric: An array of `HealthMetric` objects spanning multiple weeks.
    /// - Returns: An array of `DateValueChartData` with one entry per unique weekday,
    ///   containing the average value for that weekday. The `date` property uses
    ///   the first occurrence of that weekday from the dataset.
    ///
    /// - Note: Uses Swift Algorithms' `chunked(by:)` for efficient grouping.
    /// - Important: The returned array will have at most 7 elements (one per weekday).
    /// - SeeAlso: `Date.weekdayInt` extension for weekday integer representation.
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked(by: { $0.date.weekdayInt == $1.date.weekdayInt })
        
        var weekdayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        
        return weekdayChartData
    }
    
    // MARK: - Weight Differential Analysis
    
    /// Calculates average day-to-day weight changes grouped by weekday.
    ///
    /// This advanced method computes weight differentials (gains/losses) between consecutive
    /// days, then averages these changes by weekday. It's useful for identifying patterns like:
    /// - "I typically gain weight on weekends"
    /// - "Weight drops most on Mondays (after weekend indulgence)"
    /// - Weekly weight fluctuation trends
    ///
    /// ## Process Flow
    /// 1. **Validate**: Ensures at least 2 weight measurements exist (need pairs for diffs)
    /// 2. **Calculate Diffs**: For each day, computes `weight[i] - weight[i-1]`
    ///    - Positive value = weight gain
    ///    - Negative value = weight loss
    /// 3. **Group by Weekday**: Sorts and chunks differentials by weekday
    /// 4. **Average**: Calculates mean differential for each weekday
    /// 5. **Return**: One data point per weekday showing average weight change
    ///
    /// ### Example Calculation
    /// **Input**: Weight measurements over 8 days
    /// ```
    /// Mon Oct 13: 165.0 lbs
    /// Tue Oct 14: 164.5 lbs (diff: -0.5)
    /// Wed Oct 15: 164.0 lbs (diff: -0.5)
    /// Mon Oct 20: 166.0 lbs
    /// Tue Oct 21: 165.5 lbs (diff: -0.5)
    /// Wed Oct 22: 165.0 lbs (diff: -0.5)
    /// ```
    ///
    /// **Output**: Weekday averages
    /// ```
    /// Monday: 0.0 lbs (no previous Sunday data in this example)
    /// Tuesday: -0.5 lbs (average of -0.5, -0.5)
    /// Wednesday: -0.5 lbs (average of -0.5, -0.5)
    /// ```
    ///
    /// - Parameter weights: An array of `HealthMetric` objects representing weight measurements,
    ///   ordered chronologically. Must contain at least 2 entries.
    /// - Returns: An array of `DateValueChartData` with average weight differentials per weekday.
    ///   Returns an empty array if fewer than 2 weight measurements are provided.
    ///
    /// - Note: Weight values should be in consistent units (typically pounds).
    /// - Important: The order of the input array matters - ensure weights are chronologically sorted.
    /// - Warning: Missing days will cause larger differentials (e.g., Mon to Wed skipping Tue).
    ///
    /// ## Interpreting Results
    /// - **Positive values**: Average weight gain on that weekday
    /// - **Negative values**: Average weight loss on that weekday  
    /// - **Near zero**: Weight remains stable on that weekday
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData] {
        guard weights.count > 1 else { return [] }

        var diffValues: [(date: Date, value: Double)] = []
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeightDiff = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgWeightDiff))
        }
        
        return weekdayChartData
    }
}
