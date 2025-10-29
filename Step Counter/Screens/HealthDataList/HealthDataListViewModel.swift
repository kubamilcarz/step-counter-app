//
//  HealthDataListViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import HealthKit
import Observation
import SwiftUI

@Observable
final class HealthDataListViewModel {
    private let healthKitManager: HealthKitManager
    private let healthKitData: HealthKitData

    @ObservationIgnored
    private var addTask: Task<Void, Never>?

    let metric: HealthMetricContext

    private(set) var state: ViewState = .initial
    private(set) var errorMessage: String?
    private(set) var listData: [HealthMetric] = []

    var showAddData = false
    var addDataDate: Date = .now
    var valueToAdd = ""

    var showAlert = false
    var writeError: STError = .noData

    init(metric: HealthMetricContext, healthKitManager: HealthKitManager, healthKitData: HealthKitData) {
        self.metric = metric
        self.healthKitManager = healthKitManager
        self.healthKitData = healthKitData
        syncListData()
        state = listData.isEmpty ? .initial : .success
    }

    deinit {
        addTask?.cancel()
    }

    func onAppear() {
        syncListData()
        state = listData.isEmpty ? .initial : .success
    }

    func presentAddData() {
        addDataDate = .now
        valueToAdd = ""
        showAddData = true
    }

    func dismissAddData() {
        showAddData = false
    }

    func addData() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            valueToAdd = ""
            showAlert = true
            return
        }

        addTask?.cancel()
        state = .loading
        errorMessage = nil

        let selectedDate = addDataDate

        addTask = Task {
            do {
                if metric == .steps {
                    try await healthKitManager.addStepData(for: selectedDate, value: value)
                    let steps = try await healthKitManager.fetchStepCount()

                    healthKitData.stepData = steps
                    listData = steps.reversed()
                    valueToAdd = ""
                    addDataDate = .now
                    state = .success
                    errorMessage = nil
                    showAddData = false
                } else {
                    try await healthKitManager.addWeightData(for: selectedDate, value: value)

                    async let weightsForChart = healthKitManager.fetchWeightsCount(daysBack: 28)
                    async let weightsForDiff = healthKitManager.fetchWeightsCount(daysBack: 29)

                    let updatedWeights = try await weightsForChart
                    let updatedDiffs = try await weightsForDiff

                    healthKitData.weightData = updatedWeights
                    healthKitData.weightDiffData = updatedDiffs
                    listData = updatedWeights.reversed()
                    valueToAdd = ""
                    addDataDate = .now
                    state = .success
                    errorMessage = nil
                    showAddData = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                if let stError = error as? STError {
                    handleAddDataError(stError)
                } else if let hkError = error as? HKError, hkError.code == .errorAuthorizationDenied {
                    handleAddDataError(.sharingDenied(quantityType: metric.title.lowercased()))
                } else {
                    handleAddDataError(.unableToCompleteRequest)
                }
            }
        }
    }

    @MainActor
    private func handleAddDataError(_ error: STError) {
        writeError = error
        showAlert = true
        state = .error
        errorMessage = error.failureReason
    }

    @MainActor
    private func syncListData() {
        switch metric {
        case .steps:
            listData = healthKitData.stepData.reversed()
        case .weight:
            listData = healthKitData.weightData.reversed()
        }
    }
}
