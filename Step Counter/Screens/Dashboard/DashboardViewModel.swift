//
//  DashboardViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 05/11/2025.
//

import Foundation

@Observable
final class DashboardViewModel {
    let healthDataRepo: HealthDataRepository
    let healthDataStore: HealthDataStore
    let dataIntelligenceRepo: DataIntelligenceRepository
    let abTestRepo: ABTestRepository

    @ObservationIgnored
    private var fetchTask: Task<Void, Never>?

    private(set) var state: ViewState = .initial
    var selectedMetric: HealthMetricContext = .steps

    var showPermissionPriming = false
    var shouldShowAlert = false
    var showCoachSheet = false
    var fetchError: STError = .noData

    var stepData: [HealthMetric] {
        healthDataStore.stepData
    }

    var weightData: [HealthMetric] {
        healthDataStore.weightData
    }

    var weightDiffData: [HealthMetric] {
        healthDataStore.weightDiffData
    }

    var preselectedMetric: HealthMetricContext {
        abTestRepo.activeTests.appOpenOnHealthMetricTest
    }

    var shouldReverseCharts: Bool {
        abTestRepo.activeTests.areChartsReversedTest
    }

    init(
        healthDataRepo: HealthDataRepository,
        healthDataStore: HealthDataStore,
        dataIntelligenceRepo: DataIntelligenceRepository,
        abTestRepo: ABTestRepository
    ) {
        self.healthDataRepo = healthDataRepo
        self.healthDataStore = healthDataStore
        self.dataIntelligenceRepo = dataIntelligenceRepo
        self.abTestRepo = abTestRepo
    }

    deinit {
        fetchTask?.cancel()
    }

    func onAppear() {
        selectedMetric = preselectedMetric

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
                async let steps = healthDataRepo.fetchStepCount()
                async let weightsLine = healthDataRepo.fetchWeightsCount(daysBack: 28)
                async let weightsDiff = healthDataRepo.fetchWeightsCount(daysBack: 29)

                let (fetchedSteps, fetchedLine, fetchedDiff) = try await (steps, weightsLine, weightsDiff)

                guard !Task.isCancelled else { return }

                healthDataStore.stepData = fetchedSteps
                healthDataStore.weightData = fetchedLine
                healthDataStore.weightDiffData = fetchedDiff

                state = .success
                showPermissionPriming = false
                fetchTask = nil
            } catch STError.authNotDetermined {
                guard !Task.isCancelled else { return }

                state = .initial
                showPermissionPriming = true
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
