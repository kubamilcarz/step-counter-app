//
//  ActiveABTests.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

struct ActiveABTests: Codable {
    private(set) var appOpenOnHealthMetricTest: HealthMetricContext
    private(set) var areChartsReversedTest: Bool

    init(
        appOpenOnHealthMetricTest: HealthMetricContext,
        areChartsReversedTest: Bool
    ) {
        self.appOpenOnHealthMetricTest = appOpenOnHealthMetricTest
        self.areChartsReversedTest = areChartsReversedTest
    }

    enum CodingKeys: String, CodingKey {
        case appOpenOnHealthMetricTest = "_2025_app_open_health_metric_test"
        case areChartsReversedTest = "_2025_reverse_charts_test"
    }

    var eventParameters: [String: Any] {
        let dict: [String: Any] = [
            "test\(CodingKeys.appOpenOnHealthMetricTest.rawValue)": appOpenOnHealthMetricTest.rawValue,
            "test\(CodingKeys.areChartsReversedTest.rawValue)": areChartsReversedTest.description
        ]

        return dict.compactMapValues { $0 }
    }

    mutating func update(appOpenOnHealthMetricTest newValue: HealthMetricContext) {
        appOpenOnHealthMetricTest = newValue
    }

    mutating func update(areChartsReversedTest newValue: Bool) {
        areChartsReversedTest = newValue
    }
}
