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
    let dataIntelligenceRepo: DataIntelligenceRepository

    init(config: BuildConfiguration) {
        switch config {
        case .mock:
            healthDataRepo = MockHealthDataRepository()
            dataIntelligenceRepo = MockIntelligenceRepository()

        case .dev:
            healthDataRepo = HKHealthDataRepository()

            if #available(iOS 26.0, *) {
                dataIntelligenceRepo = HKIntelligenceRepository()
            } else {
                dataIntelligenceRepo = MockIntelligenceRepository()
            }

        case .prod:
            healthDataRepo = HKHealthDataRepository()

            if #available(iOS 26.0, *) {
                dataIntelligenceRepo = HKIntelligenceRepository()
            } else {
                dataIntelligenceRepo = MockIntelligenceRepository()
            }
        }

        // MARK: - Shared

        healthDataStore = HealthDataStore()

        // MARK: - Container Registeration

        let container = DependencyContainer()

        container.register(HealthDataRepository.self, service: healthDataRepo)
        container.register(HealthDataStore.self, service: healthDataStore)
        container.register(DataIntelligenceRepository.self, service: dataIntelligenceRepo)

        self.container = container
    }
}
