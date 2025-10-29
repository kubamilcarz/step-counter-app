//
//  Dependencies.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation

struct Dependencies {
    private let container: DependencyContainer

    let healthDataRepo: HealthDataRepository
    let healthDataStore: HealthDataStore

    init(config: BuildConfiguration) {
        switch config {
        case .mock:
            healthDataRepo = MockHealthDataRepository()
        case .dev:
            healthDataRepo = HKHealthDataRepository()
        case .prod:
            healthDataRepo = HKHealthDataRepository()
        }

        // MARK: - Shared
        healthDataStore = HealthDataStore()

        // MARK: - Container Registeration
        let container = DependencyContainer()
        
        container.register(HealthDataRepository.self, service: healthDataRepo)
        container.register(HealthDataStore.self, service: healthDataStore)
        
        self.container = container
    }
}
