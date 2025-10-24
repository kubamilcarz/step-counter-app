//
//  ChartHelper.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import Algorithms
import Foundation

/// Utility methods for processing health data for chart visualization.
struct ChartHelper {
    
    // MARK: - Data Conversion
    
    /// Converts `HealthMetric` array to `DateValueChartData` for charts.
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value) }
    }
    
    // MARK: - Statistical Calculations
    
    /// Calculates average value. Returns 0 for empty arrays.
    static func averageValue(for data: [DateValueChartData]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.value }
        return total/Double(data.count)
    }
    
    // MARK: - Chart Interaction
    
    /// Finds the data point matching the selected date (day-level comparison).
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        
        return data.first(where: {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        })
    }
    
    // MARK: - Weekday Aggregation
    
    /// Calculates average value per weekday across all weeks in the dataset.
    ///
    /// Groups metrics by weekday and returns one data point per weekday (up to 7).
    /// Useful for identifying weekly patterns.
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
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
    /// Computes `weight[i] - weight[i-1]` for each day, then averages by weekday.
    /// Returns empty array if fewer than 2 weight measurements provided.
    ///
    /// - Note: Positive = weight gain, Negative = weight loss
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData] {
        guard weights.count > 1 else { return [] }

        var diffValues: [(date: Date, value: Double)] = []
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
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
