//
//  HealthDataListViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Observation
import SwiftUI

@Observable
final class HealthDataListViewModel {
    private let healthKitData: HealthKitData

    private(set) var metric: HealthMetricContext = .steps

    private(set) var state: ViewState = .initial
    private(set) var listData: [HealthMetric] = []

    var showAddDataSheet = false

    init(healthKitData: HealthKitData) {
        self.healthKitData = healthKitData
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
        case .steps: return healthKitData.stepData
        case .weight: return healthKitData.weightData
        }
    }
}
