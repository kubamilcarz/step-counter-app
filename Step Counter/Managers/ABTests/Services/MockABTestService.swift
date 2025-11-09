//
//  MockABTestService.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation

@Observable
final class MockABTestService: ABTestService {
    var activeTests: ActiveABTests

    init(
        appOpenOnHealthMetricTest: HealthMetricContext? = nil,
        areChartsReversedTest: Bool? = nil
    ) {
        activeTests = ActiveABTests(
            appOpenOnHealthMetricTest: appOpenOnHealthMetricTest ?? .steps,
            areChartsReversedTest: areChartsReversedTest ?? false
        )
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
