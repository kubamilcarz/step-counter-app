//
//  Dependencies.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation

struct Dependencies {
    private let container: DependencyContainer

    let healthKitManager: HealthKitManager
    let healthKitData: HealthKitData

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

        healthKitManager = HealthKitManager()
        healthKitData = HealthKitData()

        let container = DependencyContainer()
        container.register(HealthKitManager.self, service: healthKitManager)
        container.register(HealthKitData.self, service: healthKitData)
        self.container = container
    }
}
