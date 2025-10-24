//
//  ChartDataTypes.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
