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
    private let healthKitManager: HealthKitManager
    private let healthKitData: HealthKitData

    private(set) var metric: HealthMetricContext = .steps

    private(set) var state: ViewState = .initial
    private(set) var listData: [HealthMetric] = []
    
    var showAddDataSheet: Bool = false

    init(healthKitManager: HealthKitManager, healthKitData: HealthKitData) {
        self.healthKitManager = healthKitManager
        self.healthKitData = healthKitData
    }

    func onAppear(config: HealthDataListViewConfig) {
        metric = config.metric
        syncListData()
        state = listData.isEmpty ? .initial : .success
    }
    
    func onAddSuccess() {
        syncListData()
        state = self.listData.isEmpty ? .initial : .success
    }
    
    func onAddButtonTapped() {
        showAddDataSheet = true
    }

    private func syncListData() {
        switch metric {
        case .steps:
            listData = Array(healthKitData.stepData.reversed())
        case .weight:
            listData = Array(healthKitData.weightData.reversed())
        }
    }
}
