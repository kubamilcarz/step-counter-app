//
//  LocalABTestService.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

final class LocalABTestService: ABTestService {
    private enum DefaultsKey {
        static let appOpenOnHealthMetricTest = ActiveABTests.CodingKeys.appOpenOnHealthMetricTest.rawValue
        static let areChartsReversedTest = ActiveABTests.CodingKeys.areChartsReversedTest.rawValue
    }

    private let userDefaults: UserDefaults

    private var appOpenOnHealthMetricTest: HealthMetricContext {
        get {
            if let rawValue = userDefaults.string(forKey: DefaultsKey.appOpenOnHealthMetricTest),
               let metric = HealthMetricContext(rawValue: rawValue) {
                return metric
            }

            let fallback = HealthMetricContext.allCases.randomElement() ?? .steps
            userDefaults.set(fallback.rawValue, forKey: DefaultsKey.appOpenOnHealthMetricTest)
            return fallback
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: DefaultsKey.appOpenOnHealthMetricTest)
        }
    }

    private var areChartsReversedTest: Bool {
        get {
            guard userDefaults.object(forKey: DefaultsKey.areChartsReversedTest) != nil else {
                let fallback = Bool.random()
                userDefaults.set(fallback, forKey: DefaultsKey.areChartsReversedTest)
                return fallback
            }

            return userDefaults.bool(forKey: DefaultsKey.areChartsReversedTest)
        }
        set {
            userDefaults.set(newValue, forKey: DefaultsKey.areChartsReversedTest)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var activeTests: ActiveABTests {
        ActiveABTests(
            appOpenOnHealthMetricTest: appOpenOnHealthMetricTest,
            areChartsReversedTest: areChartsReversedTest
        )
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        appOpenOnHealthMetricTest = updatedTests.appOpenOnHealthMetricTest
        areChartsReversedTest = updatedTests.areChartsReversedTest
    }

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
