//
//  HealthMetric.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 12/10/2025.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
