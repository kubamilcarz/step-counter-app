//
//  MockHealthDataRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@Observable
final class MockHealthDataRepository: HealthDataRepository {
    private(set) var steps: [HealthMetric] = []
    private(set) var weights: [HealthMetric] = []

    func requestAuthorization() async throws {}

    func fetchStepCount() async throws -> [HealthMetric] {
        steps
    }

    func fetchWeightsCount(daysBack _: Int) async throws -> [HealthMetric] {
        weights
    }

    func addStepData(for date: Date, value: Double) async throws {
        steps.append(.init(date: date, value: value))
    }

    func addWeightData(for date: Date, value: Double) async throws {
        weights.append(.init(date: date, value: value))
    }
}
