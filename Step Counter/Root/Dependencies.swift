//
//  Dependencies.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation

struct Dependencies {
    private let container: DependencyContainer

    let logService: LogService

    let abTestRepo: ABTestRepository
    let healthDataRepo: HealthDataRepository
    let healthDataStore: HealthDataStore
    let dataIntelligenceRepo: DataIntelligenceRepository

    init(config: BuildConfiguration) {
        switch config {
        case .mock:
            logService = LogService(clients: [MockLogClient()])

            abTestRepo = ABTestRepository(
                service: MockABTestService(),
                logService: logService
            )
            healthDataRepo = MockHealthDataRepository(steps: MockData.steps, weights: MockData.weights)

            dataIntelligenceRepo = MockIntelligenceRepository()

        case .dev:
            logService = LogService(clients: [OSLogClient()])

            abTestRepo = ABTestRepository(
                service: LocalABTestService(),
                logService: logService
            )
            healthDataRepo = HKHealthDataRepository(
                logService: logService
            )

            if #available(iOS 26.0, *) {
                dataIntelligenceRepo = HKIntelligenceRepository(
                    tools: [HealthDataTool(healthDataRepository: healthDataRepo)]
                )
            } else {
                dataIntelligenceRepo = MockIntelligenceRepository()
            }

        case .prod:
            logService = LogService(clients: [OSLogClient()])

            abTestRepo = ABTestRepository(
                service: LocalABTestService(),
                logService: logService
            )
            healthDataRepo = HKHealthDataRepository(
                logService: logService
            )

            if #available(iOS 26.0, *) {
                dataIntelligenceRepo = HKIntelligenceRepository(
                    tools: [HealthDataTool(healthDataRepository: healthDataRepo)]
                )
            } else {
                dataIntelligenceRepo = MockIntelligenceRepository()
            }
        }

        // MARK: - Shared

        healthDataStore = HealthDataStore()

        // MARK: - Container Registeration

        let container = DependencyContainer()

        container.register(LogService.self, service: logService)

        container.register(ABTestRepository.self, service: abTestRepo)
        container.register(HealthDataRepository.self, service: healthDataRepo)
        container.register(HealthDataStore.self, service: healthDataStore)
        container.register(DataIntelligenceRepository.self, service: dataIntelligenceRepo)

        self.container = container
    }
}
