//
//  StepCounterApp.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

@main
struct StepCounterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let healthKitData = HealthKitData()
    let healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            DashboardView(
                viewModel: DashboardViewModel(
                    healthKitManager: healthKitManager,
                    healthKitData: healthKitData
                )
            )
            .environment(healthKitData)
            .environment(healthKitManager)
        }
    }
}
