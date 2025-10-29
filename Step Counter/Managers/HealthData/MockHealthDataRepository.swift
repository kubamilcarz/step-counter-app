//
//  MockHealthDataRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@Observable
final class MockHealthDataRepository: HealthDataRepository {
    enum AuthorizationState {
        case notDetermined
        case granted
        case denied(Error)
    }

    private(set) var steps: [HealthMetric]
    private(set) var weights: [HealthMetric]

    /// Optional artificial delay to mimic HealthKit latency in async contexts.
    var simulatedDelay: TimeInterval
    /// Set to force the next API call to throw before returning data.
    var nextError: Error?

    @ObservationIgnored
    private var authorizationState: AuthorizationState

    init(
        steps: [HealthMetric] = [],
        weights: [HealthMetric] = [],
        authorizationState: AuthorizationState = .granted,
        simulatedDelay: TimeInterval = 0
    ) {
        self.steps = Self.sortMetrics(steps)
        self.weights = Self.sortMetrics(weights)
        self.authorizationState = authorizationState
        self.simulatedDelay = simulatedDelay
    }

    func requestAuthorization() async throws {
        switch authorizationState {
        case .granted:
            return
        case let .denied(error):
            throw error
        case .notDetermined:
            authorizationState = .granted
        }
    }

    func fetchStepCount() async throws -> [HealthMetric] {
        try await prepareForCall()
        return steps
    }

    func fetchWeightsCount(daysBack: Int) async throws -> [HealthMetric] {
        try await prepareForCall()

        guard daysBack > 0 else { return [] }

        let newestFirst = weights.sorted { $0.date > $1.date }
        let slice = Array(newestFirst.prefix(daysBack))
        return slice.sorted { $0.date < $1.date }
    }

    func addStepData(for date: Date, value: Double) async throws {
        try await prepareForCall()
        steps.append(.init(date: date, value: value))
        steps.sort { $0.date < $1.date }
    }

    func addWeightData(for date: Date, value: Double) async throws {
        try await prepareForCall()
        weights.append(.init(date: date, value: value))
        weights.sort { $0.date < $1.date }
    }

    func reset(
        steps: [HealthMetric]? = nil,
        weights: [HealthMetric]? = nil,
        authorizationState: AuthorizationState? = nil
    ) {
        if let steps { self.steps = Self.sortMetrics(steps) }
        if let weights { self.weights = Self.sortMetrics(weights) }
        if let authorizationState { self.authorizationState = authorizationState }
    }

    private func prepareForCall() async throws {
        if let error = nextError {
            nextError = nil
            throw error
        }

        if simulatedDelay > 0 {
            let delay = UInt64(simulatedDelay * 1_000_000_000)
            try await Task.sleep(nanoseconds: delay)
        }
    }

    private static func sortMetrics(_ metrics: [HealthMetric]) -> [HealthMetric] {
        metrics.sorted { $0.date < $1.date }
    }
}
