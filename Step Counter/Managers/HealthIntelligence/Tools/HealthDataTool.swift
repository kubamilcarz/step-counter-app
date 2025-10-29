//
//  HealthDataTool.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
struct HealthDataTool: Tool {
    var name = "fetchStepsAndWeight"
    var description = "Fetches the user's recent step count and weight data from HealthKit."

    private let healthDataRepository: HealthDataRepository

    init(healthDataRepository: HealthDataRepository) {
        self.healthDataRepository = healthDataRepository
    }

    @Generable()
    struct Arguments {}

    func call(arguments _: Arguments) async throws -> String {
        let steps = try await healthDataRepository.fetchStepCount().map(\.value)
        let weights = try await healthDataRepository.fetchWeightsCount(daysBack: 28).map(\.value)

        let stepsHigh = Int(steps.max() ?? 0)
        let stepsLow = Int(steps.min() ?? 0)
        let stepsTotal = Int(steps.reduce(0, +))
        let stepsAverage = Int((Double(stepsTotal) / Double(steps.count)).rounded(.up))

        let weightsHigh = Int(weights.max() ?? 0)
        let weightsLow = Int(weights.min() ?? 0)
        let weightDiff = Int(weights.first ?? 0) - Int(weights.last ?? 0)

        return """
        stepsHighestValue: \(stepsHigh),
        stepsLowestValue: \(stepsLow),
        stepsTotalValue: \(stepsTotal),
        stepsDailyAverageValue: \(stepsAverage),
        weightHighestValue: \(weightsHigh),
        weightLowestValue: \(weightsLow),
        overallWeightDiff: \(weightDiff),
        numberOfStepDays: \(steps.count)
        numberOfWeightDays: \(weights.count)
        """
    }
}
