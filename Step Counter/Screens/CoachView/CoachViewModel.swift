//
//  CoachViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import SwiftUI

@available(iOS 26.0, *)
@Observable
final class CoachViewModel {
    
    private let analyzer: DataAnalyzer
    
    init(analyzer: DataAnalyzer) {
        self.analyzer = analyzer
    }
    
    private(set) var state: ViewState = .initial
    
    var isThinking: Bool { analyzer.isThinking }
    var isAvailable: Bool { analyzer.isAvailable }
    var coachMessage: String? { analyzer.coachMessage }
    
    func onCloseButtonTapped(onDismiss: @escaping () -> Void) {
        onDismiss()
    }
}
