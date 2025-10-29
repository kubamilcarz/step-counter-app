//
//  HealthDataListViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@Observable
final class HealthDataListViewModel {
    let healthDataStore: HealthDataStore
    // Only used to initialize sub-views
    let healthDataRepo: HealthDataRepository

    private(set) var metric: HealthMetricContext = .steps

    private(set) var state: ViewState = .initial
    private(set) var listData: [HealthMetric] = []

    var showAddDataSheet = false

    init(healthDataRepo: HealthDataRepository, healthDataStore: HealthDataStore) {
        self.healthDataRepo = healthDataRepo
        self.healthDataStore = healthDataStore
    }

    func onAppear(config: HealthDataListViewConfig) {
        metric = config.metric
        syncListData()
        state = listData.isEmpty ? .initial : .success
    }

    func onAddSuccess() {
        syncListData()
        state = listData.isEmpty ? .initial : .success
    }

    func onAddButtonTapped() {
        showAddDataSheet = true
    }

    private func syncListData() {
        listData = Array(sourceData(for: metric).reversed())
    }

    private func sourceData(for metric: HealthMetricContext) -> [HealthMetric] {
        switch metric {
        case .steps: healthDataStore.stepData
        case .weight: healthDataStore.weightData
        }
    }
}
