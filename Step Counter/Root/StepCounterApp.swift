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

    var body: some Scene {
        WindowGroup {
            DashboardView(
                viewModel: DashboardViewModel(
                    healthDataRepo: delegate.dependencies.healthDataRepo,
                    healthDataStore: delegate.dependencies.healthDataStore,
                    dataIntelligenceRepo: delegate.dependencies.dataIntelligenceRepo,
                    abTestRepo: delegate.dependencies.abTestRepo,
                    logService: delegate.dependencies.logService
                )
            )
        }
    }
}
