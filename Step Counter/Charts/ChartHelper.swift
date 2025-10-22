//
//  ChartHelper.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import Foundation

struct ChartHelper {
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value) }
    }
    
    static func averageValue(for data: [DateValueChartData]) -> Double {
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.value }
        return total/Double(data.count)
    }
    
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        
        return data.first(where: {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        })
    }
}
