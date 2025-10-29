//
//  AddDataViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 01/11/2025.
//

import Foundation
import HealthKit

@Observable
final class AddDataViewModel {
    private let healthKitManager: HealthKitManager
    private let healthKitData: HealthKitData

    init(healthKitManager: HealthKitManager, healthKitData: HealthKitData) {
        self.healthKitManager = healthKitManager
        self.healthKitData = healthKitData
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
    }

    @MainActor
    func addData(onDismiss: @escaping () -> Void) {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            valueToAdd = ""
            showAlert = true
            return
        }

        addTask?.cancel()
        state = .loading

        let selectedDate = addDataDate

        addTask = Task { [weak self] in
            guard let self else { return }

            do {
                if metric == .steps {
                    try await healthKitManager.addStepData(for: selectedDate, value: value)
                    let steps = try await healthKitManager.fetchStepCount()

                    healthKitData.stepData = steps
                } else {
                    try await healthKitManager.addWeightData(for: selectedDate, value: value)

                    async let weightsForChart = healthKitManager.fetchWeightsCount(daysBack: 28)
                    async let weightsForDiff = healthKitManager.fetchWeightsCount(daysBack: 29)

                    let updatedWeights = try await weightsForChart
                    let updatedDiffs = try await weightsForDiff

                    healthKitData.weightData = updatedWeights
                    healthKitData.weightDiffData = updatedDiffs
                }

                state = .success
                valueToAdd = ""
                addDataDate = .now
                showAlert = false

                onDismiss()
            } catch {
                guard !Task.isCancelled else { return }

                let errorToHandle: STError = if let stError = error as? STError {
                    stError
                } else if let hkError = error as? HKError, hkError.code == .errorAuthorizationDenied {
                    .sharingDenied(quantityType: metric.title.lowercased())
                } else if (error as NSError).code == HKError.errorInvalidArgument.rawValue {
                    .invalidValue
                } else {
                    .unableToCompleteRequest
                }

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

        onDismiss()
    }
}
