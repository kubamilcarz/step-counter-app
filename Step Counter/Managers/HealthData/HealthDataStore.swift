//
//  HealthDataStore.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import Foundation

/// Observable container for cached HealthKit data.
///
/// Separates mutable state from `HealthDataRepository` operations for Swift 6 concurrency.
/// Inject via SwiftUI environment and update after fetching from `HealthDataRepository`.
@Observable
final class HealthDataStore: Sendable {
    /// Cached step count data (typically 28 days).
    var stepData: [HealthMetric] = []

    /// Cached weight data for line charts (typically 28 days).
    var weightData: [HealthMetric] = []

    /// Cached weight data for difference calculations (29 days - one extra for baseline).
    var weightDiffData: [HealthMetric] = []
}
