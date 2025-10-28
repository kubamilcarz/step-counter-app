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
    
    var isAvailable: Bool {
        model.isAvailable
    }
    
    private init() {}
}
