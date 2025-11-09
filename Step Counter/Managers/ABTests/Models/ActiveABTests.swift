//
//  ActiveABTests.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

/// Collection of toggles and variants that control the currently active
/// experiments inside the application.
struct ActiveABTests: Codable {
    /// Determines which metric health data should highlight when the user opens
    /// the app.
    private(set) var appOpenOnHealthMetricTest: HealthMetricContext
    /// Controls whether charts render in a reversed ordering compared to the default.
    private(set) var areChartsReversedTest: Bool

    /// Creates a new configuration describing active experiments.
    /// - Parameters:
    ///   - appOpenOnHealthMetricTest: Health metric surfaced on app launch.
    ///   - areChartsReversedTest: Flag toggling the chart orientation experiment.
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

    /// Updates the app-open metric experiment with a new value.
    mutating func update(appOpenOnHealthMetricTest newValue: HealthMetricContext) {
        appOpenOnHealthMetricTest = newValue
    }

    /// Updates the reversed-charts experiment with a new value.
    mutating func update(areChartsReversedTest newValue: Bool) {
        areChartsReversedTest = newValue
    }
}
