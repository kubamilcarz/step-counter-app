//
//  MockIntelligenceRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@available(iOS 26.0, *)
final class MockIntelligenceRepository: DataIntelligenceRepository {
    init(isAvailable: Bool, isThinking: Bool, message: String) {
        self.isAvailable = isAvailable
        self.isThinking = isThinking
        self.message = message
    }
    
    var isAvailable: Bool
    var isThinking: Bool
    var message: String
    
    func analyzeDataStream() -> AsyncThrowingStream<StreamResponse, any Error> {
        isThinking = true
        message = ""

        let mockTexts = [
            "Nice work! Over the tracked period your highest step day was 12,345 steps — an awesome achievement!",
            "Total weight change: -1.8 kg. Great progress — keep focusing on balanced meals and consistent walking for steady results. 💪"
        ]

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for text in mockTexts {
                        try await Task.sleep(nanoseconds: 300_000_000)
                        
                        message = text
                        isThinking = false
                        
                        continuation.yield(.init(text: text))
                    }
                    continuation.finish()
                } catch {
                    isThinking = false
                    
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
