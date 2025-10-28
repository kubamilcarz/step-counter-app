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
        case .mock:
            // mock-specific implementation
            break
        case .dev:
            // dev-specific implementation
            break
        case .prod:
            // prod-specific implementation
            break
        }

        let container = DependencyContainer()
        // register dependecies
        self.container = container
    }
}
