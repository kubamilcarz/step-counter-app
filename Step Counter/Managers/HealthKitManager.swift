//
//  HealthKitManager.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import Foundation
import HealthKit
import Observation

/// Observable container for cached HealthKit data.
///
/// Separates mutable state from `HealthKitManager` operations for Swift 6 concurrency.
/// Inject via SwiftUI environment and update after fetching from `HealthKitManager`.
@Observable
@MainActor
final class HealthKitData: Sendable {
    /// Cached step count data (typically 28 days).
    var stepData: [HealthMetric] = []
    
    /// Cached weight data for line charts (typically 28 days).
    var weightData: [HealthMetric] = []
    
    /// Cached weight data for difference calculations (29 days - one extra for baseline).
    var weightDiffData: [HealthMetric] = []
}

/// Handles all HealthKit data fetching and writing operations.
///
/// Stateless and thread-safe. Designed to work with `HealthKitData` for state storage.
/// Requires HealthKit authorization before use.
@Observable
final class HealthKitManager: Sendable {
    
    // MARK: - Properties
    
    /// HealthKit store for all read/write operations.
    let store = HKHealthStore()

    /// HealthKit quantity types this app accesses (stepCount, bodyMass).
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    // MARK: - Fetch methods
    
    /// Fetches step count data for the last 28 days.
    ///
    /// - Returns: Array of daily step count metrics.
    /// - Throws: `STError.authNotDetermined`, `STError.noData`, or `STError.unableToCompleteRequest`
    func fetchStepCount() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )
        
        do {
            let stepsCounts = try await stepsQuery.result(for: store)
            
            return stepsCounts.statistics().map {
                HealthMetric(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Fetches body weight measurements for a specified number of days.
    ///
    /// - Parameter daysBack: Number of days to look back from today.
    /// - Returns: Array of daily weight metrics in pounds.
    /// - Throws: `STError.authNotDetermined`, `STError.noData`, or `STError.unableToCompleteRequest`
    func fetchWeightsCount(daysBack: Int) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )
        
        do {
            let weightsCount = try await weightsQuery.result(for: store)
            
            return weightsCount.statistics().map {
                HealthMetric(
                    date: $0.startDate,
                    value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0
                )
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    // MARK: - Add data methods

    /// Adds a step count entry to HealthKit.
    ///
    /// - Parameters:
    ///   - date: Date and time for the step count.
    ///   - value: Number of steps.
    /// - Throws: `STError.authNotDetermined`, `STError.sharingDenied`, or `STError.unableToCompleteRequest`
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Adds a weight measurement to HealthKit.
    ///
    /// - Parameters:
    ///   - date: Date and time for the measurement.
    ///   - value: Weight in pounds.
    /// - Throws: `STError.authNotDetermined`, `STError.sharingDenied`, or `STError.unableToCompleteRequest`
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let weightQuanity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuanity, start: date, end: date)
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a date interval spanning from `daysBack` days ago to tomorrow.
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        return DateInterval(start: startDate, end: endDate)
    }
    
    // MARK: - Development & Testing
    
    /// Adds 28 days of mock step and weight data to HealthKit for simulator testing.
    ///
    /// - Warning: Uses `try!` - only call in development/simulator environments.
    func addSimulatorData() async {
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<28 {
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
            let weightQuanity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
            
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
            
            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuanity, start: startDate, end: endDate)
            
            mockSamples.append(stepSample)
            mockSamples.append(weightSample)
        }
        
        try! await store.save(mockSamples)
        print("Dummy data added")
    }
}
