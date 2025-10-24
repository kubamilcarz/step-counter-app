//
//  HealthMetric.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 12/10/2025.
//

import Foundation

/// A data model representing a single health measurement retrieved from HealthKit.
///
/// `HealthMetric` serves as the core data structure for all health-related information
/// fetched from Apple's HealthKit framework. It provides a simplified, app-specific
/// representation of HealthKit data that can be easily manipulated and displayed.
///
/// ## Supported Health Metrics
/// This model is used to represent various health data types, including:
/// - **Step Count**: Daily step counts from the device's motion sensors
/// - **Body Weight**: Weight measurements in pounds
/// - **Active Energy**: Calories burned (if implemented)
/// - **Distance**: Walking/running distance (if implemented)
///
/// ## Data Flow
/// ```
/// HealthKit Store
///     ↓ (Query)
/// HKStatistics / HKQuantitySample
///     ↓ (Transform)
/// HealthMetric
///     ↓ (Convert)
/// DateValueChartData (for charts)
/// ```
///
/// ## Usage Example
/// ```swift
/// // Fetched from HealthKitManager
/// let steps = try await healthManager.fetchStepCount()
/// // steps is [HealthMetric]
///
/// // Convert for chart display
/// let chartData = ChartHelper.convert(data: steps)
/// ```
///
/// - Note: This is a lightweight model focused on date-value pairs. Additional metadata
///   from HealthKit (like source, device, etc.) is intentionally omitted.
/// - SeeAlso: `DateValueChartData` for the chart-specific representation
/// - SeeAlso: `HealthKitManager` for methods that create and return these metrics
struct HealthMetric: Identifiable {
    
    /// A unique identifier for this health metric instance.
    ///
    /// Automatically generated UUID that allows conformance to `Identifiable`.
    /// This enables the struct to be used in SwiftUI's `ForEach`, `List`, and other
    /// collection views without requiring manual ID specification.
    ///
    /// - Note: The ID is regenerated each time data is fetched from HealthKit,
    ///   even if the underlying health data hasn't changed.
    let id = UUID()
    
    /// The date and time when this health measurement was recorded or applies to.
    ///
    /// The granularity and meaning of this date depends on the metric type:
    ///
    /// ### For Daily Aggregates (Step Count, Weight)
    /// - Normalized to the start of the day (00:00:00)
    /// - Represents the calendar day the measurement applies to
    /// - Example: October 24, 2025, 12:00 AM
    ///
    /// ### For Point-in-Time Measurements
    /// - Contains the exact timestamp of the measurement
    /// - Example: October 24, 2025, 3:45 PM
    ///
    /// - Important: When comparing dates, use `Calendar.current.isDate(_:inSameDayAs:)`
    ///   for day-level comparisons to ignore time components.
    /// - SeeAlso: `Date+Ext.swift` for date manipulation helpers
    let date: Date
    
    /// The numerical value of the health measurement.
    ///
    /// The interpretation and unit of this value is context-dependent based on the metric type:
    ///
    /// | Metric Type | Unit | Example Value | Interpretation |
    /// |------------|------|---------------|----------------|
    /// | Step Count | steps | 8542.0 | Total steps taken that day |
    /// | Body Weight | pounds | 165.5 | Weight measurement in lbs |
    /// | Weight Diff | pounds | -0.5 | Change from previous measurement |
    /// | Distance | miles | 4.2 | Distance walked/run |
    /// | Calories | kcal | 450.0 | Active energy burned |
    ///
    /// ### Value Ranges
    /// - **Step Count**: Typically 0 - 50,000 (0 for inactive days, up to marathon-level activity)
    /// - **Body Weight**: Typically 50 - 500 lbs (varies by individual)
    /// - **Weight Diff**: Typically -5.0 to +5.0 lbs (daily fluctuations)
    ///
    /// - Important: The unit is **not** stored in this model. Ensure proper unit handling
    ///   in the code that creates or consumes these metrics.
    /// - Note: A value of 0.0 may indicate either no data or an actual zero measurement,
    ///   depending on context. Check the source method's documentation for clarification.
    let value: Double
}
