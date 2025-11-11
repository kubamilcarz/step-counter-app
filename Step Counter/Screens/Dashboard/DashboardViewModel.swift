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
    let logService: LogService?

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
        abTestRepo: ABTestRepository,
        logService: LogService?
    ) {
        self.healthDataRepo = healthDataRepo
        self.healthDataStore = healthDataStore
        self.dataIntelligenceRepo = dataIntelligenceRepo
        self.abTestRepo = abTestRepo
        self.logService = logService
    }

    deinit {
        fetchTask?.cancel()
    }

    func onAppear() {
        selectedMetric = preselectedMetric

        logService?.trackEvent(event: Event.viewAppeared(selectedMetric: preselectedMetric))
        fetchHealthData()
    }

    func onPermissionSheetDismissed() {
        logService?.trackEvent(event: Event.permissionSheetDismissed)
        fetchHealthData()
    }

    func fetchHealthData() {
        fetchTask?.cancel()
        state = .loading
        shouldShowAlert = false
        logService?.trackEvent(event: Event.fetchStarted(metric: selectedMetric))

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
                logService?.trackEvent(event: Event.fetchSucceeded(metric: selectedMetric))
            } catch STError.authNotDetermined {
                guard !Task.isCancelled else { return }

                state = .initial
                showPermissionPriming = true
                fetchTask = nil
                logService?.trackEvent(event: Event.fetchAuthNotDetermined)
            } catch STError.noData {
                guard !Task.isCancelled else { return }

                state = .error
                fetchError = .noData
                shouldShowAlert = true
                fetchTask = nil
                logService?.trackEvent(event: Event.fetchNoData(metric: selectedMetric))
            } catch {
                guard !Task.isCancelled else { return }

                state = .error
                fetchError = .unableToCompleteRequest
                shouldShowAlert = true
                fetchTask = nil
                logService?.trackEvent(event: Event.fetchFailed(metric: selectedMetric, error: error))
            }
        }
    }
}

extension DashboardViewModel {
    enum Event: LoggableEvent {
        case viewAppeared(selectedMetric: HealthMetricContext)
        case permissionSheetDismissed
        case fetchStarted(metric: HealthMetricContext)
        case fetchSucceeded(metric: HealthMetricContext)
        case fetchFailed(metric: HealthMetricContext, error: Error)
        case fetchNoData(metric: HealthMetricContext)
        case fetchAuthNotDetermined

        var eventName: String {
            switch self {
            case .viewAppeared: "Dashboard_View_Appeared"
            case .permissionSheetDismissed: "Dashboard_PermissionSheet_Dismissed"
            case .fetchStarted: "Dashboard_Fetch_Started"
            case .fetchSucceeded: "Dashboard_Fetch_Succeeded"
            case .fetchFailed: "Dashboard_Fetch_Failed"
            case .fetchNoData: "Dashboard_Fetch_NoData"
            case .fetchAuthNotDetermined: "Dashboard_Fetch_AuthNotDetermined"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .viewAppeared(selectedMetric):
                ["metric": selectedMetric.rawValue]
            case let .fetchStarted(metric):
                ["metric": metric.rawValue]
            case let .fetchSucceeded(metric):
                ["metric": metric.rawValue]
            case let .fetchFailed(metric, error):
                ["metric": metric.rawValue, "error": error.localizedDescription]
            case let .fetchNoData(metric):
                ["metric": metric.rawValue]
            case .permissionSheetDismissed, .fetchAuthNotDetermined:
                nil
            }
        }

        var type: LogType {
            switch self {
            case .fetchFailed: .warning
            case .fetchNoData: .info
            case .fetchAuthNotDetermined: .info
            default: .analytic
            }
        }
    }
}
