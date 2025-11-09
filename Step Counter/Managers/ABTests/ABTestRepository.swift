//
//  ABTestRepository.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

/// Coordinates active A/B test values for the current session while delegating
/// persistence concerns to an injected `ABTestService`.
@Observable
final class ABTestRepository {
    private let service: ABTestService

    /// Snapshot of the currently active tests that view models can observe.
    var activeTests: ActiveABTests

    /// Creates a repository that wraps the provided service and immediately
    /// attempts to synchronise the local state with the latest configuration.
    /// - Parameter service: Concrete implementation responsible for storing
    /// and retrieving A/B test overrides.
    init(service: ABTestService) {
        self.service = service
        activeTests = service.activeTests

        configure()
    }

    /// Pumps the latest configuration from the service into the observable
    /// `activeTests` property.
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

    /// Persists a caller-provided override and refreshes the repository state.
    /// - Parameter updatedTests: Fresh set of tests to store.
    /// - Throws: Any error bubbling up from the service while saving.
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
}
