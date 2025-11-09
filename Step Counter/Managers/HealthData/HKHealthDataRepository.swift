//
//  HKHealthDataRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation
import HealthKit

/// Handles all HealthKit data fetching and writing operations.
///
/// Stateless and thread-safe. Designed to work with `HealthDataStore` for state storage.
/// Requires HealthKit authorization before use.
@Observable
final class HKHealthDataRepository: HealthDataRepository {
    // MARK: - Properties

    /// HealthKit store for all read/write operations.
    private let store = HKHealthStore()
    private let logService: LogService?

    /// HealthKit quantity types this app accesses (stepCount, bodyMass).
    private let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]

    init(logService: LogService?) {
        self.logService = logService
    }

    // MARK: - Authorization

    /// Requests read/write authorization for all configured HealthKit quantity types.
    ///
    /// Automatically surfaces the system permission sheet when needed.
    /// - Throws: `STError.unableToCompleteRequest`, `STError.sharingDenied`, or `STError.authNotDetermined`.
    func requestAuthorization() async throws {
        logService?.trackEvent(event: Event.authorizationStarted)

        guard HKHealthStore.isHealthDataAvailable() else {
            let error = STError.unableToCompleteRequest
            logService?.trackEvent(event: Event.authorizationFailed(error: error))
            throw error
        }

        do {
            try await store.requestAuthorization(toShare: types, read: types)
        } catch {
            logService?.trackEvent(event: Event.authorizationFailed(error: error))
            throw STError.unableToCompleteRequest
        }

        let stepStatus = store.authorizationStatus(for: HKQuantityType(.stepCount))
        let weightStatus = store.authorizationStatus(for: HKQuantityType(.bodyMass))

        guard stepStatus != .notDetermined, weightStatus != .notDetermined else {
            let error = STError.authNotDetermined
            logService?.trackEvent(event: Event.authorizationFailed(error: error))
            throw error
        }

        if stepStatus == .sharingDenied {
            let error = STError.sharingDenied(quantityType: "step count")
            logService?.trackEvent(event: Event.authorizationFailed(error: error))
            throw error
        }

        if weightStatus == .sharingDenied {
            let error = STError.sharingDenied(quantityType: "weight")
            logService?.trackEvent(event: Event.authorizationFailed(error: error))
            throw error
        }

        logService?.trackEvent(event: Event.authorizationSucceeded)
    }

    // MARK: - Fetch methods

    /// Fetches step count data for the last 28 days.
    ///
    /// - Returns: Array of daily step count metrics.
    /// - Throws: `STError.authNotDetermined`, `STError.noData`, or `STError.unableToCompleteRequest`
    func fetchStepCount() async throws -> [HealthMetric] {
        logService?.trackEvent(event: Event.fetchStepsStarted)

        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            let error = STError.authNotDetermined
            logService?.trackEvent(event: Event.fetchStepsFailed(error: error))
            throw error
        }

        let interval = Date.now.createDateInterval(daysBack: 28)

        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.stepCount),
            predicate: queryPredicate
        )

        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )

        do {
            let stepsCounts = try await stepsQuery.result(for: store)

            let metrics = stepsCounts.statistics().map {
                HealthMetric(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }

            logService?.trackEvent(event: Event.fetchStepsSucceeded(count: metrics.count))
            return metrics
        } catch HKError.errorNoData {
            let error = STError.noData
            logService?.trackEvent(event: Event.fetchStepsFailed(error: error))
            throw error
        } catch {
            logService?.trackEvent(event: Event.fetchStepsFailed(error: error))
            throw STError.unableToCompleteRequest
        }
    }

    /// Fetches body weight measurements for a specified number of days.
    ///
    /// - Parameter daysBack: Number of days to look back from today.
    /// - Returns: Array of daily weight metrics in pounds.
    /// - Throws: `STError.authNotDetermined`, `STError.noData`, or `STError.unableToCompleteRequest`
    func fetchWeightsCount(daysBack: Int) async throws -> [HealthMetric] {
        logService?.trackEvent(event: Event.fetchWeightsStarted(daysBack: daysBack))

        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            let error = STError.authNotDetermined
            logService?.trackEvent(event: Event.fetchWeightsFailed(error: error))
            throw error
        }

        let interval = Date.now.createDateInterval(daysBack: daysBack)

        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.bodyMass),
            predicate: queryPredicate
        )

        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )

        do {
            let weightsCount = try await weightsQuery.result(for: store)

            let metrics = weightsCount.statistics().map {
                HealthMetric(
                    date: $0.startDate,
                    value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0
                )
            }

            logService?.trackEvent(event: Event.fetchWeightsSucceeded(count: metrics.count))
            return metrics
        } catch HKError.errorNoData {
            let error = STError.noData
            logService?.trackEvent(event: Event.fetchWeightsFailed(error: error))
            throw error
        } catch {
            logService?.trackEvent(event: Event.fetchWeightsFailed(error: error))
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
        logService?.trackEvent(event: Event.addStepDataStarted(value: value))

        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            let error = STError.authNotDetermined
            logService?.trackEvent(event: Event.addStepDataFailed(error: error))
            throw error

        case .sharingDenied:
            let error = STError.sharingDenied(quantityType: "step count")
            logService?.trackEvent(event: Event.addStepDataFailed(error: error))
            throw error

        case .sharingAuthorized:
            break

        @unknown default:
            break
        }

        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: stepQuantity,
            start: date,
            end: date
        )

        do {
            try await store.save(stepSample)
            logService?.trackEvent(event: Event.addStepDataSucceeded)
        } catch {
            logService?.trackEvent(event: Event.addStepDataFailed(error: error))
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
        logService?.trackEvent(event: Event.addWeightDataStarted(value: value))

        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        switch status {
        case .notDetermined:
            let error = STError.authNotDetermined
            logService?.trackEvent(event: Event.addWeightDataFailed(error: error))
            throw error

        case .sharingDenied:
            let error = STError.sharingDenied(quantityType: "weight")
            logService?.trackEvent(event: Event.addWeightDataFailed(error: error))
            throw error

        case .sharingAuthorized:
            break

        @unknown default:
            break
        }

        let weightQuanity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: weightQuanity,
            start: date,
            end: date
        )

        do {
            try await store.save(weightSample)
            logService?.trackEvent(event: Event.addWeightDataSucceeded)
        } catch {
            logService?.trackEvent(event: Event.addWeightDataFailed(error: error))
            throw STError.unableToCompleteRequest
        }
    }

    // MARK: - Development & Testing

    // - Warning: Uses `try!` - only call in development/simulator environments.
//    func addSimulatorData() async {
//        var mockSamples: [HKQuantitySample] = []
//
//        for i in 0..<28 {
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
//            let weightQuanity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 +
//            Double(i/3))))
//
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//
//            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start:
//            startDate, end: endDate)
//            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuanity, start:
//            startDate, end: endDate)
//
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//        }
//
//        try? await store.save(mockSamples)
//        print("Dummy data added")
//    }
}

extension HKHealthDataRepository {
    enum Event: LoggableEvent {
        case authorizationStarted
        case authorizationFailed(error: Error)
        case authorizationSucceeded

        case fetchStepsStarted
        case fetchStepsSucceeded(count: Int)
        case fetchStepsFailed(error: Error)

        case fetchWeightsStarted(daysBack: Int)
        case fetchWeightsSucceeded(count: Int)
        case fetchWeightsFailed(error: Error)

        case addStepDataStarted(value: Double)
        case addStepDataSucceeded
        case addStepDataFailed(error: Error)

        case addWeightDataStarted(value: Double)
        case addWeightDataSucceeded
        case addWeightDataFailed(error: Error)

        var eventName: String {
            switch self {
            case .authorizationStarted: "HealthData_Authorization_Started"
            case .authorizationFailed: "HealthData_Authorization_Failed"
            case .authorizationSucceeded: "HealthData_Authorization_Succeeded"
            case .fetchStepsStarted: "HealthData_FetchSteps_Started"
            case .fetchStepsSucceeded: "HealthData_FetchSteps_Succeeded"
            case .fetchStepsFailed: "HealthData_FetchSteps_Failed"
            case .fetchWeightsStarted: "HealthData_FetchWeights_Started"
            case .fetchWeightsSucceeded: "HealthData_FetchWeights_Succeeded"
            case .fetchWeightsFailed: "HealthData_FetchWeights_Failed"
            case .addStepDataStarted: "HealthData_AddSteps_Started"
            case .addStepDataSucceeded: "HealthData_AddSteps_Succeeded"
            case .addStepDataFailed: "HealthData_AddSteps_Failed"
            case .addWeightDataStarted: "HealthData_AddWeight_Started"
            case .addWeightDataSucceeded: "HealthData_AddWeight_Succeeded"
            case .addWeightDataFailed: "HealthData_AddWeight_Failed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .authorizationFailed(error),
                 let .fetchStepsFailed(error),
                 let .fetchWeightsFailed(error),
                 let .addStepDataFailed(error),
                 let .addWeightDataFailed(error):
                ["error": error.localizedDescription]
            case let .fetchStepsSucceeded(count):
                ["count": count]
            case let .fetchWeightsStarted(daysBack):
                ["daysBack": daysBack]
            case let .fetchWeightsSucceeded(count):
                ["count": count]
            case let .addStepDataStarted(value):
                ["value": value]
            case let .addWeightDataStarted(value):
                ["value": value]
            default:
                nil
            }
        }

        var type: LogType {
            switch self {
            case .authorizationFailed,
                 .fetchStepsFailed,
                 .fetchWeightsFailed:
                .warning
            case .addStepDataFailed,
                 .addWeightDataFailed:
                .severe
            default:
                .analytic
            }
        }
    }
}
