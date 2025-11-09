//
//  ABTestRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

@Observable
final class ABTestRepository {
    private let service: ABTestService

    var activeTests: ActiveABTests

    init(service: ABTestService) {
        self.service = service
        activeTests = service.activeTests

        configure()
    }

    private func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
            } catch {
                // catch error with logger
                print("Error")
            }
        }
    }

    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
}
