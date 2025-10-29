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
    private let analyzer: DataAnalyzer

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    private(set) var state: ViewState = .initial
    private(set) var errorMessage: String?
    private(set) var coachMessage: String?

    init(analyzer: DataAnalyzer) {
        self.analyzer = analyzer
    }

    deinit {
        loadTask?.cancel()
    }

    var isThinking: Bool { analyzer.isThinking }
    var isAvailable: Bool { analyzer.isAvailable }

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
                let stream = analyzer.analyzeHealthDataStream()

                var receivedMessage = false

                for try await partial in stream {
                    guard !Task.isCancelled else { return }

                    let text = String(describing: partial)
                    coachMessage = text

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
