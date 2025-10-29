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

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    private(set) var state: ViewState = .initial
    private(set) var errorMessage: String?
    private(set) var coachMessage: String?

    init(dataIntelligenceRepo: DataIntelligenceRepository) {
        self.dataIntelligenceRepo = dataIntelligenceRepo
    }

    deinit {
        loadTask?.cancel()
    }

    var isThinking: Bool { dataIntelligenceRepo.isThinking }
    var isAvailable: Bool { dataIntelligenceRepo.isAvailable }

    func onCloseButtonTapped(onDismiss: @escaping () -> Void) {
        onDismiss()
    }

    func onAppear() {
        guard state == .initial else { return }
        guard isAvailable else {
            state = .error
            errorMessage = String(localized: "Coach Craig is not available on this device yet.")
            return
        }
        loadCoachInsights()
    }
    
    func onViewDisappear() {
        // TODO: clear coach message
    }

    func onRetryButtonTapped() {
        guard state != .loading else { return }
        guard isAvailable else {
            state = .error
            errorMessage = String(localized: "Coach Craig is not available on this device yet.")
            return
        }
        loadCoachInsights()
    }

    private func loadCoachInsights() {
        loadTask?.cancel()
        coachMessage = nil
        state = .loading
        errorMessage = nil

        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.loadTask = nil }

            do {
                let stream = dataIntelligenceRepo.analyzeDataStream()

                var receivedMessage = false

                for try await partial in stream {
                    guard !Task.isCancelled else { return }

                    coachMessage = partial.text

                    if !receivedMessage {
                        state = .success
                        receivedMessage = true
                    }
                }

                if !receivedMessage {
                    state = .error
                    errorMessage =
                        String(localized: "Coach Craig could not generate insights right now. Please try again.")
                }
            } catch {
                guard !Task.isCancelled else { return }
                state = .error
                errorMessage = error.localizedDescription
            }
        }
    }
}
