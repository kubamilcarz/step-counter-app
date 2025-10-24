//
//  ChartDataTypes.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

/// A data model representing a single chart data point with a date and numerical value.
///
/// This structure is used throughout the app's charting system to represent time-series data
/// such as step counts, weight measurements, and other health metrics. It conforms to
/// `Identifiable` for use in SwiftUI lists and charts, and `Equatable` for comparison operations.
///
/// ## Common Use Cases
/// - Displaying step count data in bar charts
/// - Plotting weight trends in line charts
/// - Showing average values by weekday in pie charts
/// - Representing any time-based health metric visualization
///
/// ## SwiftUI Charts Integration
/// ```swift
/// Chart(chartData) { dataPoint in
///     BarMark(
///         x: .value("Date", dataPoint.date),
///         y: .value("Steps", dataPoint.value)
///     )
/// }
/// ```
///
/// - Note: Each instance has a unique UUID for identification in SwiftUI collections.
/// - SeeAlso: `HealthMetric` for the raw health data model that gets converted to this type.
struct DateValueChartData: Identifiable, Equatable {
    
    /// A unique identifier for this chart data point.
    ///
    /// Automatically generated UUID that allows this struct to conform to `Identifiable`.
    /// This enables the struct to be used directly in SwiftUI `ForEach` and `Chart` views
    /// without requiring explicit ID specification.
    let id = UUID()
    
    /// The date associated with this data point.
    ///
    /// Represents the timestamp for the measurement. Typically normalized to the start
    /// of the day for daily metrics (e.g., step counts, daily weight), but can represent
    /// any point in time depending on the metric type.
    ///
    /// - Note: When comparing dates, use `Calendar.current.isDate(_:inSameDayAs:)` for day-level comparisons.
    let date: Date
    
    /// The numerical value of the metric at the specified date.
    ///
    /// The interpretation of this value depends on the metric type:
    /// - **Step Count**: Total steps for the day (e.g., 8,542)
    /// - **Weight**: Body mass in pounds (e.g., 165.5)
    /// - **Weight Difference**: Change in weight in pounds (e.g., -0.5 for loss, +1.2 for gain)
    /// - **Average Values**: Calculated averages for specific groupings (e.g., average steps per weekday)
    ///
    /// - Important: Units are context-dependent. Always document the expected unit when using this type.
    let value: Double
}
