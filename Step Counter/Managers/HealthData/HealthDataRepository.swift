//
//  HealthDataRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

protocol HealthDataRepository: Sendable {
    func requestAuthorization() async throws
    func fetchStepCount() async throws -> [HealthMetric]
    func fetchWeightsCount(daysBack: Int) async throws -> [HealthMetric]
    func addStepData(for date: Date, value: Double) async throws
    func addWeightData(for date: Date, value: Double) async throws
}
