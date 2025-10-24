//
//  Step_Counter_Tests.swift
//  Step Counter Tests
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import Foundation
import Testing
@testable import Step_Counter

struct Step_Counter_Tests {

    @Test func arrayAverages() async throws {
        let array: [Double] = [2.0, 3.1, 0.45, 1.84]
        #expect(array.average == 1.8475)
    }
}

@Suite("Chart Helper Tests")
struct ChartHelperTests {
    var metrics: [HealthMetric] = [
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 1_000),
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 750),
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 500),
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 12))!, value: 1_250),
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 15))!, value: 250),
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 16))!, value: 1_000),
        .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 17))!, value: 1_500)
    ]
    
    @MainActor @Test func averageWeekdayCount() {
        let averageWeekdayCount = ChartHelper.averageWeekdayCount(for: metrics)
        #expect(averageWeekdayCount.count == 4)
        #expect(averageWeekdayCount[0].value == 1_000.0)
        #expect(averageWeekdayCount[1].value == 1_125.0)
        #expect(averageWeekdayCount[2].date.weekdayTitle == "Wednesday")
    }
}