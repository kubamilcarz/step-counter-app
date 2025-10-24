//
//  Step_CounterApp.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

@main
struct Step_CounterApp: App {
    let healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(healthKitManager)
        }
    }
}
