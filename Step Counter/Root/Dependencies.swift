//
//  Dependencies.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation

struct Dependencies {
    private let container: DependencyContainer
    
    init(config: BuildConfiguration) {
        switch config {
        case .mock(let isPremium, let isConnected):
            // mock-specific implementation
        case .dev:
            // dev-specific implementation
        case .prod:
            // prod-specific implementation
        }
        
        let container = DependencyContainer()
        // register dependecies
        self.container = container
    }
}
