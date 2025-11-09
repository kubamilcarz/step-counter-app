//
//  HKIntelligenceRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation
import FoundationModels

/// Apple Intelligence-backed repository that streams motivational fitness coaching based on Health data.
@available(iOS 26.0, *)
@Observable
final class HKIntelligenceRepository: DataIntelligenceRepository {
    private let tools: [any Tool]
    let model: SystemLanguageModel = .default
    var coachMessage: String?
    var isThinking = false

    /// Creates the repository with a preconfigured toolchain for the language model session.
    /// - Parameter tools: Tool definitions exposed to the language model. Defaults to an empty array for tests.
    init(tools: [any Tool] = []) {
        self.tools = tools
    }

    var isAvailable: Bool {
        model.isAvailable
    }

    var message: String {
        coachMessage ?? ""
    }

    func analyzeDataStream() -> AsyncThrowingStream<StreamResponse, Error> {
        isThinking = true
        coachMessage = nil

        let session = LanguageModelSession(
            tools: tools,
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
                    for try await partial in responseStream {
                        let text = String(describing: partial.content)
                        guard text != "null" else { continue }

                        await MainActor.run {
                            self.coachMessage = text
                            self.isThinking = false
                        }
                        continuation.yield(.init(text: text))
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

    func clearMessage() {
        coachMessage = nil
    }
}
