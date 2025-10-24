//
//  HealthKitManager.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import Foundation
import HealthKit
import Observation

/// A container class for storing cached HealthKit data.
///
/// `HealthKitData` serves as a separate, observable data store for health metrics
/// fetched from HealthKit. This separation follows Swift 6 concurrency best practices
/// by isolating mutable state from the `HealthKitManager` operations class.
///
/// ## Architecture Pattern
/// This class implements the separation of concerns pattern:
/// - **HealthKitData**: Holds mutable cached data (State)
/// - **HealthKitManager**: Performs HealthKit operations (Behavior)
///
/// ## Thread Safety
/// - Marked with `@MainActor` to ensure all property updates occur on the main thread
/// - Conforms to `Sendable` for safe concurrency
/// - Automatically observable via `@Observable` macro for SwiftUI integration
///
/// ## Usage Example
/// ```swift
/// @main
/// struct MyApp: App {
///     let healthKitData = HealthKitData()
///     let healthKitManager = HealthKitManager()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(healthKitData)
///                 .environment(healthKitManager)
///         }
///     }
/// }
///
/// // In a view
/// @Environment(HealthKitData.self) private var healthKitData
/// let chartData = ChartHelper.convert(data: healthKitData.stepData)
/// ```
///
/// - Note: This class should be instantiated once at the app level and injected via SwiftUI environment.
/// - Important: All properties are updated by `HealthKitManager` after successful data fetches.
/// - SeeAlso: `HealthKitManager` for methods that populate these properties.
@Observable
@MainActor
final class HealthKitData: Sendable {
    
    /// Cached array of step count metrics.
    ///
    /// Each metric contains a date and the corresponding step count value.
    /// This array is automatically updated when new data is fetched via
    /// `HealthKitManager.fetchStepCount()`.
    ///
    /// - Note: Typically contains 28 days of historical step data.
    /// - SeeAlso: `HealthKitManager.fetchStepCount()`
    var stepData: [HealthMetric] = []
    
    /// Cached array of body weight metrics.
    ///
    /// Each metric contains a date and the corresponding weight value in pounds.
    /// This array is automatically updated when new data is fetched via
    /// `HealthKitManager.fetchWeightsCount(daysBack:)`.
    ///
    /// - Note: Typically contains 28 days of historical weight data for line charts.
    /// - SeeAlso: `HealthKitManager.fetchWeightsCount(daysBack:)`
    var weightData: [HealthMetric] = []
    
    /// Cached array of weight metrics used for calculating daily differences.
    ///
    /// This array stores one additional day of weight data (29 days) compared to
    /// `weightData` to enable day-to-day difference calculations. The extra day
    /// provides the baseline for computing the first day's differential.
    ///
    /// - Note: Contains 29 days of data to calculate 28 days of weight differences.
    /// - SeeAlso: `ChartHelper.averageDailyWeightDiffs(for:)` for the calculation logic.
    var weightDiffData: [HealthMetric] = []
}

/// A manager class responsible for handling all HealthKit interactions.
///
/// This class provides a centralized interface for:
/// - Requesting and managing HealthKit permissions
/// - Fetching health data (step counts and body weight)
/// - Adding new health data entries
///
/// ## Architecture
/// As of Swift 6, this class is designed to be stateless and thread-safe:
/// - Conforms to `Sendable` for safe concurrency
/// - Does not store mutable state (data is stored in `HealthKitData`)
/// - All methods are async and can be called from any context
///
/// ## Usage Example
/// ```swift
/// let healthManager = HealthKitManager()
/// let healthData = HealthKitData()
///
/// // Fetch and store data
/// healthData.stepData = try await healthManager.fetchStepCount()
/// healthData.weightData = try await healthManager.fetchWeightsCount(daysBack: 28)
/// ```
///
/// - Note: This class requires HealthKit authorization before performing any operations.
/// - Important: All fetch and add methods are asynchronous and may throw errors.
/// - SeeAlso: `HealthKitData` for the companion data storage class.
@Observable
final class HealthKitManager: Sendable {
    
    // MARK: - Properties
    
    /// The shared HealthKit store instance used for all health data operations.
    ///
    /// This store provides access to the HealthKit database and handles all read/write operations.
    let store = HKHealthStore()

    /// The set of HealthKit quantity types that this app requests access to.
    ///
    /// Currently includes:
    /// - `stepCount`: Daily step count data
    /// - `bodyMass`: Body weight measurements
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    // MARK: - Fetch methods
    
    /// Fetches step count data for the last 28 days.
    ///
    /// This method queries HealthKit for daily step count statistics over a 28-day period
    /// ending at the current date. The data is aggregated by day, with each day's steps
    /// summed into a single cumulative value.
    ///
    /// ## Process Flow
    /// 1. Verifies HealthKit authorization status
    /// 2. Creates a date interval for the last 28 days
    /// 3. Constructs a statistics collection query
    /// 4. Executes the query and processes results
    /// 5. Maps results to `HealthMetric` objects
    ///
    /// - Returns: An array of `HealthMetric` objects, each containing a date and step count value.
    /// - Throws:
    ///   - `STError.authNotDetermined`: If HealthKit authorization has not been requested
    ///   - `STError.noData`: If no step count data is available for the specified period
    ///   - `STError.unableToCompleteRequest`: If the query fails for any other reason
    ///
    /// - Note: The returned array will contain one entry per day, even if no steps were recorded (value will be 0).
    /// - Important: This method requires prior authorization to read step count data.
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
    
    /// Fetches body weight measurements for a specified number of days in the past.
    ///
    /// This method queries HealthKit for daily body weight data over a custom time period.
    /// For each day, it retrieves the most recent weight measurement (if multiple exist).
    ///
    /// ## Process Flow
    /// 1. Verifies HealthKit authorization status
    /// 2. Creates a date interval based on the specified number of days
    /// 3. Constructs a statistics collection query with `.mostRecent` option
    /// 4. Executes the query and processes results
    /// 5. Maps results to `HealthMetric` objects with values in pounds
    ///
    /// - Parameter daysBack: The number of days to look back from today. Must be a positive integer.
    /// - Returns: An array of `HealthMetric` objects, each containing a date and weight value in pounds.
    /// - Throws:
    ///   - `STError.authNotDetermined`: If HealthKit authorization has not been requested
    ///   - `STError.noData`: If no weight data is available for the specified period
    ///   - `STError.unableToCompleteRequest`: If the query fails for any other reason
    ///
    /// - Note: Days without recorded weight measurements will have a value of 0.
    /// - Important: Weight values are returned in pounds. Convert if needed for other units.
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

    /// Adds a new step count entry to HealthKit for a specific date.
    ///
    /// This method creates and saves a new step count sample to the HealthKit store.
    /// It performs authorization checks before attempting to save the data.
    ///
    /// ## Process Flow
    /// 1. Checks current authorization status for step count data
    /// 2. Validates that sharing is authorized
    /// 3. Creates an `HKQuantity` with the specified step count
    /// 4. Creates an `HKQuantitySample` for the given date
    /// 5. Saves the sample to the HealthKit store
    ///
    /// ## Authorization States
    /// - `.notDetermined`: Authorization not yet requested → Throws error
    /// - `.sharingDenied`: User denied write permission → Throws error
    /// - `.sharingAuthorized`: Write permission granted → Proceeds with save
    ///
    /// - Parameters:
    ///   - date: The date and time for which the step count should be recorded.
    ///   - value: The number of steps to record. Must be a non-negative value.
    /// - Throws:
    ///   - `STError.authNotDetermined`: If HealthKit authorization has not been requested
    ///   - `STError.sharingDenied`: If the user has denied write permission for step count
    ///   - `STError.unableToCompleteRequest`: If saving the data fails
    ///
    /// - Important: This method requires write permission for step count data.
    /// - Warning: Adding data with a future date may cause unexpected behavior.
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
    
    /// Adds a new body weight entry to HealthKit for a specific date.
    ///
    /// This method creates and saves a new weight measurement sample to the HealthKit store.
    /// It performs authorization checks before attempting to save the data.
    ///
    /// ## Process Flow
    /// 1. Checks current authorization status for body mass data
    /// 2. Validates that sharing is authorized
    /// 3. Creates an `HKQuantity` with the specified weight in pounds
    /// 4. Creates an `HKQuantitySample` for the given date
    /// 5. Saves the sample to the HealthKit store
    ///
    /// ## Authorization States
    /// - `.notDetermined`: Authorization not yet requested → Throws error
    /// - `.sharingDenied`: User denied write permission → Throws error
    /// - `.sharingAuthorized`: Write permission granted → Proceeds with save
    ///
    /// - Parameters:
    ///   - date: The date and time for which the weight should be recorded.
    ///   - value: The weight measurement in pounds. Must be a positive value.
    /// - Throws:
    ///   - `STError.authNotDetermined`: If HealthKit authorization has not been requested
    ///   - `STError.sharingDenied`: If the user has denied write permission for weight
    ///   - `STError.unableToCompleteRequest`: If saving the data fails
    ///
    /// - Important: Weight values must be provided in pounds (lb).
    /// - Note: Multiple weight entries can exist for the same day; HealthKit will track all of them.
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
    
    /// Creates a date interval for querying HealthKit data.
    ///
    /// This private helper method generates a `DateInterval` that spans from a calculated
    /// start date to the end of the specified reference date. The interval is calculated
    /// by going back a specified number of days from the reference date.
    ///
    /// ## Calculation Logic
    /// 1. Gets the start of day for the reference date
    /// 2. Adds 1 day to get the end date (to include the full reference day)
    /// 3. Subtracts the specified number of days to get the start date
    /// 4. Returns an interval spanning from start to end
    ///
    /// ### Example
    /// If called with:
    /// - `date`: October 24, 2025, 3:45 PM
    /// - `daysBack`: 7
    ///
    /// Returns interval from:
    /// - Start: October 17, 2025, 12:00 AM
    /// - End: October 25, 2025, 12:00 AM
    ///
    /// - Parameters:
    ///   - date: The reference date from which to calculate the interval.
    ///   - daysBack: The number of days to look back from the reference date.
    /// - Returns: A `DateInterval` spanning the calculated time period.
    ///
    /// - Note: This method uses the current calendar to ensure proper date calculations.
    /// - Important: The end date is extended by 1 day to ensure the full reference day is included.
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        return DateInterval(start: startDate, end: endDate)
    }
    
    // MARK: - Development & Testing
    
    /// Populates HealthKit with simulated data for testing and development purposes.
    ///
    /// This method generates and saves mock health data to HealthKit, including both
    /// step counts and weight measurements for the last 28 days. This is useful for:
    /// - Testing the app in the iOS Simulator (where real HealthKit data doesn't exist)
    /// - Development and UI testing
    /// - Demonstrating app functionality
    ///
    /// ## Generated Data
    /// - **Step Count**: Random values between 4,000 and 20,000 steps per day
    /// - **Body Weight**: Random values with a gradual upward trend
    ///   - Base range: 160-165 lbs
    ///   - Trend: Increases by ~1 lb every 3 days
    ///
    /// ## Process Flow
    /// 1. Creates an empty array for mock samples
    /// 2. Iterates through the last 28 days
    /// 3. For each day, generates random step and weight values
    /// 4. Creates `HKQuantitySample` objects for both metrics
    /// 5. Saves all samples to HealthKit in a single batch operation
    ///
    /// - Warning: This method uses force-try (`try!`) and will crash if HealthKit save fails.
    ///   Only use in development/simulator environments.
    /// - Note: Prints "Dummy data added" to console upon successful completion.
    /// - Important: Do not call this method in production builds or with real user data.
    ///
    /// ## Usage Example
    /// ```swift
    /// #if DEBUG
    /// await healthManager.addSimulatorData()
    /// #endif
    /// ```
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
