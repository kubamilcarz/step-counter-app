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
    let logService: LogService?

    private(set) var metric: HealthMetricContext = .steps

    private(set) var state: ViewState = .initial
    private(set) var listData: [HealthMetric] = []

    var showAddDataSheet = false

    init(healthDataRepo: HealthDataRepository, healthDataStore: HealthDataStore, logService: LogService?) {
        self.healthDataRepo = healthDataRepo
        self.healthDataStore = healthDataStore
        self.logService = logService
    }

    func onAppear(config: HealthDataListViewConfig) {
        metric = config.metric
        syncListData()
        state = listData.isEmpty ? .initial : .success

        logService?.trackEvent(event: Event.viewAppeared(metric: metric, itemCount: listData.count))
    }

    func onAddSuccess() {
        syncListData()
        state = listData.isEmpty ? .initial : .success

        logService?.trackEvent(event: Event.addCompleted(metric: metric, itemCount: listData.count))
    }

    func onAddButtonTapped() {
        showAddDataSheet = true
        logService?.trackEvent(event: Event.addTapped(metric: metric))
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

extension HealthDataListViewModel {
    enum Event: LoggableEvent {
        case viewAppeared(metric: HealthMetricContext, itemCount: Int)
        case addTapped(metric: HealthMetricContext)
        case addCompleted(metric: HealthMetricContext, itemCount: Int)

        var eventName: String {
            switch self {
            case .viewAppeared: "HealthDataList_View_Appeared"
            case .addTapped: "HealthDataList_Add_Tapped"
            case .addCompleted: "HealthDataList_Add_Completed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .viewAppeared(metric, itemCount):
                ["metric": metric.rawValue, "itemCount": itemCount]
            case let .addTapped(metric):
                ["metric": metric.rawValue]
            case let .addCompleted(metric, itemCount):
                ["metric": metric.rawValue, "itemCount": itemCount]
            }
        }

        var type: LogType {
            switch self {
            case .addTapped: .info
            default: .analytic
            }
        }
    }
}
