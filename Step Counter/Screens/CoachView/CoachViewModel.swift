//
//  CoachViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Observation
import SwiftUI

@available(iOS 26.0, *)
@Observable
final class CoachViewModel {
    private let analyzer: DataAnalyzer

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    private(set) var state: ViewState = .initial
    private(set) var errorMessage: String?

    init(analyzer: DataAnalyzer) {
        self.analyzer = analyzer
    }

    deinit {
        loadTask?.cancel()
    }

    var isAvailable: Bool { analyzer.isAvailable }
    var coachMessage: String? { analyzer.coachMessage.map(String.init(describing:)) }

    func onCloseButtonTapped(onDismiss: @escaping () -> Void) {
        onDismiss()
    }

    func onAppear() {
        guard state == .initial else { return }
        guard isAvailable else {
            state = .error
            errorMessage = "Coach Craig is not available on this device yet."
            return
        }
        loadCoachInsights()
    }

    func onRetryButtonTapped() {
        guard state != .loading else { return }
        guard isAvailable else {
            state = .error
            errorMessage = "Coach Craig is not available on this device yet."
            return
        }
        loadCoachInsights()
    }

    private func loadCoachInsights() {
        loadTask?.cancel()
        analyzer.coachMessage = nil
        state = .loading
        errorMessage = nil

        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await analyzer.analyzeHealthData()

                if analyzer.coachMessage != nil {
                    state = .success
                } else {
                    state = .error
                    errorMessage = "Coach Craig could not generate insights right now. Please try again."
                }

                loadTask = nil
            } catch {
                guard !Task.isCancelled else { return }
                state = .error
                errorMessage = error.localizedDescription
                loadTask = nil
            }
        }
    }
}
