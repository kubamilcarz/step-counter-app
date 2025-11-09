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
    private let logService: LogService?

    /// Snapshot of the currently active tests that view models can observe.
    var activeTests: ActiveABTests

    /// Creates a repository that wraps the provided service and immediately
    /// attempts to synchronise the local state with the latest configuration.
    /// - Parameter service: Concrete implementation responsible for storing
    /// and retrieving A/B test overrides.
    init(service: ABTestService, logService: LogService?) {
        self.service = service
        self.logService = logService
        activeTests = service.activeTests

        configure()
    }

    /// Pumps the latest configuration from the service into the observable
    /// `activeTests` property.
    private func configure() {
        Task {
            logService?.trackEvent(event: Event.configurationStarted)
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logService?.trackEvent(event: Event.configurationSuccess)
            } catch {
                logService?.trackEvent(event: Event.configurationFailed(error: error))
            }
        }
    }

    /// Persists a caller-provided override and refreshes the repository state.
    /// - Parameter updatedTests: Fresh set of tests to store.
    /// - Throws: Any error bubbling up from the service while saving.
    func override(updatedTests: ActiveABTests) throws {
        logService?.trackEvent(event: Event.updateStarted)
        try service.saveUpdatedConfig(updatedTests: updatedTests)

        logService?.trackEvent(event: Event.updateSuccess)
        configure()
    }
}

extension ABTestRepository {
    enum Event: LoggableEvent {
        case configurationStarted
        case configurationSuccess
        case configurationFailed(error: Error)
        case updateStarted
        case updateSuccess

        var eventName: String {
            switch self {
            case .configurationStarted: "ABTests_Config_Started"
            case .configurationSuccess: "ABTests_Config_Success"
            case .configurationFailed: "ABTests_Config_Failed"
            case .updateStarted: "ABTests_Update_Started"
            case .updateSuccess: "ABTests_Update_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .configurationFailed(error):
                ["error": error.localizedDescription]
            default: nil
            }
        }

        var type: LogType {
            switch self {
            case .configurationFailed: .warning
            default: .analytic
            }
        }
    }
}
