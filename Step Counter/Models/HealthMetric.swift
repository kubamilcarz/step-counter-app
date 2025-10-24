//
//  HealthMetric.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 12/10/2025.
//

import Foundation

/// A health measurement from HealthKit with a date and value.
///
/// Used for step counts, body weight, and other health metrics.
/// Convert to `DateValueChartData` for chart display.
struct HealthMetric: Identifiable {
    /// Unique identifier for SwiftUI collections.
    let id = UUID()
    
    /// Date of the measurement (typically start of day for daily metrics).
    let date: Date
    
    /// Metric value (steps as count, weight in pounds, etc.).
    let value: Double
}
