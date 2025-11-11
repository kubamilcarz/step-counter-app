//
//  CoachViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation

@available(iOS 26.0, *)
@Observable
final class CoachViewModel {
    private let dataIntelligenceRepo: DataIntelligenceRepository
    private let logService: LogService?

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    private(set) var state: ViewState = .initial
    private(set) var errorMessage: String?
    private(set) var coachMessage: String?

    init(dataIntelligenceRepo: DataIntelligenceRepository, logService: LogService?) {
        self.dataIntelligenceRepo = dataIntelligenceRepo
        self.logService = logService
    }

    deinit {
        loadTask?.cancel()
    }

    var isThinking: Bool { dataIntelligenceRepo.isThinking }
    var isAvailable: Bool { dataIntelligenceRepo.isAvailable }

    func onCloseButtonTapped(onDismiss: @escaping () -> Void) {
        logService?.trackEvent(event: Event.closeTapped)
        onDismiss()
    }

    func onAppear() {
        logService?.trackEvent(event: Event.viewAppeared)
        guard state == .initial else { return }
        guard isAvailable else {
            state = .error
            errorMessage = String(localized: "Coach Craig is not available on this device yet.")
            logService?.trackEvent(event: Event.unavailable)
            return
        }
        loadCoachInsights()
    }

    func onViewDisappear() {
        logService?.trackEvent(event: Event.viewDismissed)
        dataIntelligenceRepo.clearMessage()
    }

    func onRetryButtonTapped() {
        guard state != .loading else { return }
        guard isAvailable else {
            state = .error
            errorMessage = String(localized: "Coach Craig is not available on this device yet.")
            logService?.trackEvent(event: Event.unavailable)
            return
        }
        logService?.trackEvent(event: Event.retryTapped)
        loadCoachInsights()
    }

    private func loadCoachInsights() {
        loadTask?.cancel()
        coachMessage = nil
        state = .loading
        errorMessage = nil
        logService?.trackEvent(event: Event.fetchStarted)

        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }

            do {
                let stream = dataIntelligenceRepo.analyzeDataStream()

                var receivedMessage = false

                for try await partial in stream {
                    guard !Task.isCancelled else { return }

                    coachMessage = partial.text
                    logService?.trackEvent(event: Event.messageReceived)

                    if !receivedMessage {
                        state = .success
                        receivedMessage = true
                        logService?.trackEvent(event: Event.fetchSucceeded)
                    }
                }

                if !receivedMessage {
                    state = .error
                    errorMessage =
                        String(localized: "Coach Craig could not generate insights right now. Please try again.")
                    logService?.trackEvent(event: Event.emptyResponse)
                }
            } catch let error as STError {
                guard !Task.isCancelled else { return }
                state = .error
                errorMessage = error.failureReason
                logService?.trackEvent(event: Event.fetchFailed(error: error))
            } catch {
                guard !Task.isCancelled else { return }
                state = .error
                errorMessage = error.localizedDescription
                logService?.trackEvent(event: Event.fetchFailed(error: STError.unableToCompleteRequest))
            }
        }
    }
}

@available(iOS 26.0, *)
extension CoachViewModel {
    enum Event: LoggableEvent {
        case viewAppeared
        case viewDismissed
        case closeTapped
        case retryTapped
        case fetchStarted
        case fetchSucceeded
        case fetchFailed(error: STError)
        case emptyResponse
        case unavailable
        case messageReceived

        var eventName: String {
            switch self {
            case .viewAppeared: "Coach_View_Appeared"
            case .viewDismissed: "Coach_View_Dismissed"
            case .closeTapped: "Coach_Close_Tapped"
            case .retryTapped: "Coach_Retry_Tapped"
            case .fetchStarted: "Coach_Fetch_Started"
            case .fetchSucceeded: "Coach_Fetch_Succeeded"
            case .fetchFailed: "Coach_Fetch_Failed"
            case .emptyResponse: "Coach_Fetch_Empty"
            case .unavailable: "Coach_Unavailable"
            case .messageReceived: "Coach_Message_Received"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .fetchFailed(error):
                ["error": error.localizedDescription]
            default:
                nil
            }
        }

        var type: LogType {
            switch self {
            case .fetchFailed: .warning
            case .emptyResponse: .warning
            case .unavailable: .info
            default: .analytic
            }
        }
    }
}
