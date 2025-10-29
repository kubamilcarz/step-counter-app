//
//  DashboardViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 05/11/2025.
//

import Foundation

@Observable
final class DashboardViewModel {
    private let healthKitManager: HealthKitManager
    private let healthKitData: HealthKitData

    @ObservationIgnored
    private var fetchTask: Task<Void, Never>?

    private(set) var state: ViewState = .initial
    var selectedMetric: HealthMetricContext = .steps

    var shouldShowPermissionPriming = false
    var shouldShowAlert = false
    var shouldShowCoachSheet = false
    var fetchError: STError = .noData

    init(healthKitManager: HealthKitManager, healthKitData: HealthKitData) {
        self.healthKitManager = healthKitManager
        self.healthKitData = healthKitData
    }

    deinit {
        fetchTask?.cancel()
    }

    func onAppear() {
        fetchHealthData()
    }

    func onPermissionSheetDismissed() {
        fetchHealthData()
    }

    func fetchHealthData() {
        fetchTask?.cancel()
        state = .loading
        shouldShowAlert = false

        fetchTask = Task { [weak self] in
            guard let self else { return }

            do {
                async let steps = healthKitManager.fetchStepCount()
                async let weightsLine = healthKitManager.fetchWeightsCount(daysBack: 28)
                async let weightsDiff = healthKitManager.fetchWeightsCount(daysBack: 29)

                let (fetchedSteps, fetchedLine, fetchedDiff) = try await (steps, weightsLine, weightsDiff)

                guard !Task.isCancelled else { return }

                healthKitData.stepData = fetchedSteps
                healthKitData.weightData = fetchedLine
                healthKitData.weightDiffData = fetchedDiff
                state = .success
                shouldShowPermissionPriming = false
                fetchTask = nil
            } catch STError.authNotDetermined {
                guard !Task.isCancelled else { return }

                state = .initial
                shouldShowPermissionPriming = true
                fetchTask = nil
            } catch STError.noData {
                guard !Task.isCancelled else { return }

                state = .error
                fetchError = .noData
                shouldShowAlert = true
                fetchTask = nil
            } catch {
                guard !Task.isCancelled else { return }

                state = .error
                fetchError = .unableToCompleteRequest
                shouldShowAlert = true
                fetchTask = nil
            }
        }
    }
}
