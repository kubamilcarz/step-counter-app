//
//  ChartDataTypes.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

/// A chart data point with a date and numerical value.
///
/// Used throughout the app for SwiftUI Charts. Convert from `HealthMetric` using `ChartHelper.convert()`.
struct DateValueChartData: Identifiable, Equatable {
    /// Unique identifier for SwiftUI collections.
    let id = UUID()
    
    /// Date for the data point.
    let date: Date
    
    /// Metric value (context-dependent: steps, weight, weight diff, etc.).
    let value: Double
}
