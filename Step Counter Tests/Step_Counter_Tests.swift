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
    
    // MARK: - Average Weekday Count Tests
    
    @MainActor @Test func averageWeekdayCount_withMultipleWeeks() {
        // June 9, 2025 = Monday
        // June 10 = Tuesday
        // June 11 = Wednesday
        // June 12 = Thursday
        // June 15 = Sunday
        // June 16 = Monday
        // June 17 = Tuesday
        let metrics: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 1_000),   // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 750),    // Tue
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 500),    // Wed
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 12))!, value: 1_250),  // Thu
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 15))!, value: 250),    // Sun
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 16))!, value: 1_000),  // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 17))!, value: 1_500)   // Tue
        ]
        
        let result = ChartHelper.averageWeekdayCount(for: metrics)
        
        // Should have 5 unique weekdays (Mon, Tue, Wed, Thu, Sun)
        #expect(result.count == 5)
        
        // Find Sunday (should be 250)
        let sunday = result.first { $0.date.weekdayInt == 1 }
        #expect(sunday?.value == 250.0)
        
        // Find Monday (average of 1000 and 1000 = 1000)
        let monday = result.first { $0.date.weekdayInt == 2 }
        #expect(monday?.value == 1_000.0)
        
        // Find Tuesday (average of 750 and 1500 = 1125)
        let tuesday = result.first { $0.date.weekdayInt == 3 }
        #expect(tuesday?.value == 1_125.0)
        #expect(tuesday?.date.weekdayTitle == "Tuesday")
        
        // Find Wednesday (should be 500)
        let wednesday = result.first { $0.date.weekdayInt == 4 }
    }
    
    @MainActor @Test func averageWeekdayCount_withSingleWeek() {
        let metrics: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 1_000),   // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 2_000),  // Tue
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 3_000)   // Wed
        ]
        
        let result = ChartHelper.averageWeekdayCount(for: metrics)
        
        // Should have 3 unique weekdays, each with their single value
        #expect(result.count == 3)
        #expect(result[0].value == 1_000.0)
        #expect(result[1].value == 2_000.0)
        #expect(result[2].value == 3_000.0)
    }
    
    @MainActor @Test func averageWeekdayCount_withEmptyArray() {
        let metrics: [HealthMetric] = []
        let result = ChartHelper.averageWeekdayCount(for: metrics)
        #expect(result.isEmpty)
    }
    
    // MARK: - Average Daily Weight Diffs Tests
    
    @MainActor @Test func averageDailyWeightDiffs_withConsecutiveDays() {
        // Test with simple consecutive days showing weight loss
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 170.0),   // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 169.5),  // Tue: -0.5
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 169.0),  // Wed: -0.5
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 12))!, value: 168.5)   // Thu: -0.5
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        
        // Should have 3 results (4 weights = 3 diffs)
        #expect(result.count == 3)
        
        // All diffs should be -0.5
        let tuesday = result.first { $0.date.weekdayInt == 3 }
        #expect(tuesday?.value == -0.5)
        
        let wednesday = result.first { $0.date.weekdayInt == 4 }
        #expect(wednesday?.value == -0.5)
        
        let thursday = result.first { $0.date.weekdayInt == 5 }
        #expect(thursday?.value == -0.5)
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withWeightGain() {
        // Test with weight gain over weekend
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 13))!, value: 165.0),  // Fri
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 14))!, value: 166.0),  // Sat: +1.0
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 15))!, value: 167.0),  // Sun: +1.0
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 16))!, value: 166.0)   // Mon: -1.0
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        
        #expect(result.count == 3)
        
        // Saturday should show +1.0 gain
        let saturday = result.first { $0.date.weekdayInt == 7 }
        #expect(saturday?.value == 1.0)
        
        // Sunday should show +1.0 gain
        let sunday = result.first { $0.date.weekdayInt == 1 }
        #expect(sunday?.value == 1.0)
        
        // Monday should show -1.0 loss
        let monday = result.first { $0.date.weekdayInt == 2 }
        #expect(monday?.value == -1.0)
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withMultipleWeeksAveraged() {
        // Test averaging across multiple weeks of same weekday
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 170.0),   // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 169.0),  // Tue: -1.0
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 168.0),  // Wed: -1.0
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 16))!, value: 170.0),  // Mon (next week)
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 17))!, value: 169.0),  // Tue: -1.0
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 18))!, value: 169.5)   // Wed: +0.5
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        
        // Tuesday appears twice: -1.0 and -1.0, average = -1.0
        let tuesday = result.first { $0.date.weekdayInt == 3 }
        #expect(tuesday?.value == -1.0)
        
        // Wednesday appears twice: -1.0 and +0.5, average = -0.25
        let wednesday = result.first { $0.date.weekdayInt == 4 }
        #expect(wednesday?.value == -0.25)
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withFluctuatingWeights() {
        // Test with realistic weight fluctuations
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 165.0),   // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 164.8),  // Tue: -0.2
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 165.1),  // Wed: +0.3
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 12))!, value: 164.9),  // Thu: -0.2
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 13))!, value: 165.2)   // Fri: +0.3
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        
        #expect(result.count == 4)
        
        // Verify each diff
        let tuesday = result.first { $0.date.weekdayInt == 3 }
        #expect(tuesday?.value ?? 0 <= -0.19 && tuesday?.value ?? 0 >= -0.21) // Handle floating point
        
        let wednesday = result.first { $0.date.weekdayInt == 4 }
        #expect(wednesday?.value ?? 0 >= 0.29 && wednesday?.value ?? 0 <= 0.31) // Handle floating point
        
        let thursday = result.first { $0.date.weekdayInt == 5 }
        #expect(thursday?.value ?? 0 <= -0.19 && thursday?.value ?? 0 >= -0.21) // Handle floating point
        
        let friday = result.first { $0.date.weekdayInt == 6 }
        #expect(friday?.value ?? 0 >= 0.29 && friday?.value ?? 0 <= 0.31) // Handle floating point
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withSingleWeight() {
        // Edge case: only one weight, no diffs possible
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 165.0)
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        #expect(result.isEmpty)
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withTwoWeights() {
        // Edge case: two weights = one diff
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 165.0),   // Mon
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 164.0)   // Tue: -1.0
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        
        #expect(result.count == 1)
        #expect(result[0].value == -1.0)
        #expect(result[0].date.weekdayInt == 3) // Tuesday
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withEmptyArray() {
        let weights: [HealthMetric] = []
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        #expect(result.isEmpty)
    }
    
    @MainActor @Test func averageDailyWeightDiffs_withZeroChanges() {
        // Test with no weight changes
        let weights: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 9))!, value: 165.0),
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 10))!, value: 165.0),
            .init(date: Calendar.current.date(from: .init(year: 2025, month: 6, day: 11))!, value: 165.0)
        ]
        
        let result = ChartHelper.averageDailyWeightDiffs(for: weights)
        
        #expect(result.count == 2)
        #expect(result[0].value == 0.0)
        #expect(result[1].value == 0.0)
    }
}
