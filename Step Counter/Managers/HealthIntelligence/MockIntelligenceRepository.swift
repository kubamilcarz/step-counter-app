//
//  MockIntelligenceRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@Observable
final class MockIntelligenceRepository: DataIntelligenceRepository {
    var isAvailable: Bool
    var isThinking: Bool
    var message: String

    /// Ordered list of canned responses streamed back to the UI.
    var responseTexts: [String]
    /// Optional delay between streamed chunks to mimic on-device processing.
    var simulatedDelay: TimeInterval
    /// Supply an error to have the next stream fail immediately.
    var nextError: Error?

    static let defaultResponses = [
        "Nice work! Your best day hit 12,345 steps - keep that streak alive!",
        "Weight change over the last check-ins: -1.8 kg. Awesome progress - keep fueling with lean protein and consistent walks. 💪",
        "Remember to stay hydrated and take breaks during your workouts!",
        "Consistency is key! Aim for at least 30 minutes of activity most days of the week.",
        "Mix up your workouts to keep things interesting and target different muscle groups."
    ]

    init(
        isAvailable: Bool = true,
        isThinking: Bool = false,
        message: String = "",
        responseTexts: [String] = MockIntelligenceRepository.defaultResponses,
        simulatedDelay: TimeInterval = 0.2
    ) {
        self.isAvailable = isAvailable
        self.isThinking = isThinking
        self.message = message
        self.responseTexts = responseTexts
        self.simulatedDelay = simulatedDelay
    }

    func analyzeDataStream() -> AsyncThrowingStream<StreamResponse, Error> {
        isThinking = true
        message = ""

        let responses = responseTexts.isEmpty ? Self.defaultResponses : responseTexts
        let delay = simulatedDelay

        return AsyncThrowingStream { continuation in
            let streamTask = Task {
                do {
                    guard isAvailable else {
                        throw STError.intelligenceUnavailable
                    }

                    if let error = nextError {
                        nextError = nil
                        throw error
                    }

                    let chosen = responses.randomElement() ?? responses.first!
                    let words = chosen.split(separator: " ").map(String.init)
                    var partial = ""

                    for (index, word) in words.enumerated() {
                        guard !Task.isCancelled else { return }

                        partial += (index == 0 ? "" : " ") + word
                        message = partial
                        continuation.yield(.init(text: partial))

                        if delay > 0 {
                            let nanos = UInt64(delay * 700_000_000)
                            try await Task.sleep(nanoseconds: nanos)
                        }
                    }

                    message = chosen

                    isThinking = false
                    continuation.finish()
                } catch {
                    isThinking = false

                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                streamTask.cancel()
            }
        }
    }

    func clearMessage() {
        message = ""
    }

    func replaceResponses(with texts: [String]) {
        responseTexts = texts
    }
}
