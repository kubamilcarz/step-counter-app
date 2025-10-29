//
//  HealthKitPermissionPrimingViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Observation
import SwiftUI

@Observable
final class HealthKitPermissionPrimingViewModel {
    private let healthKitManager: HealthKitManager
    
    private(set) var state: ViewState = .initial
    var shouldShowErrorAlert = false
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
    }
    
    let description = """
    This app displays your step and weight data in interactive charts.

    You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
    """
    
    @MainActor
    func onConnectButtonTapped(onDismiss: @escaping () -> Void) async {
        state = .loading
        shouldShowErrorAlert = false

        do {
            try await healthKitManager.requestAuthorization()
            state = .success
            onDismiss()
        } catch {
            state = .error
            shouldShowErrorAlert = true
        }
    }
}
