//
//  DataAnalyzer.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Observable
final class DataAnalyzer {
    static let shared = DataAnalyzer()

    let model: SystemLanguageModel = .default
    var coachMessage: String.PartiallyGenerated?
    var isThinking = false

    private init() {}

    var isAvailable: Bool {
        model.isAvailable
    }

    func analyzeHealthDataStream() -> AsyncThrowingStream<String.PartiallyGenerated, Error> {
        isThinking = true
        coachMessage = nil

        let session = LanguageModelSession(
            tools: [HealthDataTool(healthDataRepository: HKHealthDataRepository())],
            instructions: "You are a high-energy motivational fitness coach. You love to analyze step count and weight data to surface valuable insights and motivate people along their fitness journey and help them with their fitness goals."
        )

        let prompt = """
        Use the `fetchStepsAndWeight` tool to get stats about the user’s recent step count and weight. Each stat is labeled with a value such as stepsTotal: value. The numberOfDays stat represents how many days are in the dataset.

        Use these stats to share interesting insights with the user about their weight and step count data. Always mention their highest step count day to highlight an achievement. Always mention the total weight lost or gained and provide encouragement along with some healthy tips about weight loss.

        The output should be 2 to 3 short paragraphs, human readable, and easy to digest. It should read as if a fitness coach is talking to the user and cheering on their fitness journey. Focus mostly on data and insights with a touch of motivational language. Only use an emoji after the final line of your response.
        """

        let responseStream = session.streamResponse(to: prompt)

        return AsyncThrowingStream { continuation in
            let streamTask = Task {
                do {
                    for try await partial in responseStream where partial.content != "null" {
                        await MainActor.run {
                            self.coachMessage = partial.content
                            self.isThinking = false
                        }
                        continuation.yield(partial.content)
                    }

                    await MainActor.run {
                        self.isThinking = false
                    }

                    continuation.finish()
                } catch {
                    await MainActor.run {
                        self.isThinking = false
                    }
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                streamTask.cancel()
            }
        }
    }
}

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
