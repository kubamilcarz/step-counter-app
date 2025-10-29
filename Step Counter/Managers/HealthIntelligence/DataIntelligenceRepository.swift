//
//  DataIntelligenceRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@available(iOS 26.0, *)
protocol DataIntelligenceRepository: Sendable {
    var isAvailable: Bool { get }
    var isThinking: Bool { get }
    var message: String { get }
    
    func analyzeDataStream() -> AsyncThrowingStream<StreamResponse, Error>
}
