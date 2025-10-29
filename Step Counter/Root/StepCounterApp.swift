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
                    healthKitManager: delegate.dependencies.healthKitManager,
                    healthKitData: delegate.dependencies.healthKitData
                )
            )
            .environment(delegate.dependencies.healthKitData)
            .environment(delegate.dependencies.healthKitManager)
        }
    }
}
