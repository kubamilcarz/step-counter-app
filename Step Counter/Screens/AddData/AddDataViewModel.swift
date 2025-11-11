//
//  AddDataViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 01/11/2025.
//

import Foundation

@Observable
final class AddDataViewModel {
    private let healthDataRepo: HealthDataRepository
    private let healthDataStore: HealthDataStore
    private let logService: LogService?

    init(healthDataRepo: HealthDataRepository, healthDataStore: HealthDataStore, logService: LogService?) {
        self.healthDataRepo = healthDataRepo
        self.healthDataStore = healthDataStore
        self.logService = logService
    }

    @ObservationIgnored
    private var addTask: Task<Void, Never>?

    private(set) var metric: HealthMetricContext = .steps
    private(set) var state: ViewState = .initial
    var addDataDate: Date = .now
    var valueToAdd = ""

    var showAlert = false
    var writeError: STError = .noData

    deinit {
        addTask?.cancel()
    }

    @MainActor
    func onViewAppear(config: AddDataViewConfig) {
        metric = config.metric
        addDataDate = .now
        valueToAdd = ""
        state = .initial
        showAlert = false

        logService?.trackEvent(event: Event.viewAppeared(metric: metric))
    }

    @MainActor
    func addData(onDismiss: @escaping () -> Void) {
        let pendingValue = valueToAdd

        guard let value = Double(pendingValue) else {
            logService?.trackEvent(event: Event.invalidInput(metric: metric, input: pendingValue))
            writeError = .invalidValue
            valueToAdd = ""
            showAlert = true
            return
        }

        logService?.trackEvent(event: Event.addDataStarted(metric: metric, value: value))
        addTask?.cancel()
        state = .loading

        let selectedDate = addDataDate

        addTask = Task { [weak self] in
            guard let self else { return }

            do {
                if metric == .steps {
                    try await healthDataRepo.addStepData(for: selectedDate, value: value)
                    let steps = try await healthDataRepo.fetchStepCount()

                    healthDataStore.stepData = steps
                } else {
                    try await healthDataRepo.addWeightData(for: selectedDate, value: value)

                    async let weightsForChart = healthDataRepo.fetchWeightsCount(daysBack: 28)
                    async let weightsForDiff = healthDataRepo.fetchWeightsCount(daysBack: 29)

                    let updatedWeights = try await weightsForChart
                    let updatedDiffs = try await weightsForDiff

                    healthDataStore.weightData = updatedWeights
                    healthDataStore.weightDiffData = updatedDiffs
                }

                logService?.trackEvent(event: Event.addDataSucceeded(metric: metric))
                state = .success
                valueToAdd = ""
                addDataDate = .now
                showAlert = false

                onDismiss()
            } catch {
                guard !Task.isCancelled else { return }

                let errorToHandle: STError = if let stError = error as? STError {
                    stError
                } else {
                    .unableToCompleteRequest
                }

                logService?.trackEvent(event: Event.addDataFailed(metric: metric, error: errorToHandle))
                state = .error
                writeError = errorToHandle
                showAlert = true
            }
        }
    }

    func onCancel(onDismiss: @escaping () -> Void) {
        addTask?.cancel()
        addTask = nil
        addDataDate = .now
        valueToAdd = ""
        state = .initial
        showAlert = false

        logService?.trackEvent(event: Event.cancelled(metric: metric))
        onDismiss()
    }
}

extension AddDataViewModel {
    enum Event: LoggableEvent {
        case viewAppeared(metric: HealthMetricContext)
        case addDataStarted(metric: HealthMetricContext, value: Double)
        case addDataSucceeded(metric: HealthMetricContext)
        case addDataFailed(metric: HealthMetricContext, error: STError)
        case invalidInput(metric: HealthMetricContext, input: String)
        case cancelled(metric: HealthMetricContext)

        var eventName: String {
            switch self {
            case .viewAppeared: "AddData_View_Appeared"
            case .addDataStarted: "AddData_Submit_Started"
            case .addDataSucceeded: "AddData_Submit_Succeeded"
            case .addDataFailed: "AddData_Submit_Failed"
            case .invalidInput: "AddData_Submit_InvalidInput"
            case .cancelled: "AddData_Submit_Cancelled"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .viewAppeared(metric):
                ["metric": metric.rawValue]
            case let .addDataStarted(metric, value):
                ["metric": metric.rawValue, "value": value]
            case let .addDataSucceeded(metric):
                ["metric": metric.rawValue]
            case let .addDataFailed(metric, error):
                ["metric": metric.rawValue, "error": error.localizedDescription]
            case let .invalidInput(metric, input):
                ["metric": metric.rawValue, "input": input]
            case let .cancelled(metric):
                ["metric": metric.rawValue]
            }
        }

        var type: LogType {
            switch self {
            case .addDataFailed: .severe
            case .invalidInput: .warning
            case .cancelled: .info
            default: .analytic
            }
        }
    }
}
