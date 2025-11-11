//
//  HealthKitPermissionPrimingViewModel.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import Foundation

@Observable
final class HealthKitPermissionPrimingViewModel {
    private let healthDataRepo: HealthDataRepository
    private let logService: LogService?

    private(set) var state: ViewState = .initial
    var shouldShowErrorAlert = false

    init(healthDataRepo: HealthDataRepository, logService: LogService?) {
        self.healthDataRepo = healthDataRepo
        self.logService = logService
    }

    let description = String(localized: """
    This app displays your step and weight data in interactive charts.

    You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
    """)

    func onViewAppear() {
        logService?.trackEvent(event: Event.viewAppeared)
    }

    func onViewDisappear() {
        logService?.trackEvent(event: Event.viewDisappeared)
    }

    @MainActor
    func onConnectButtonTapped(onDismiss: @escaping () -> Void) async {
        logService?.trackEvent(event: Event.connectTapped)
        state = .loading
        shouldShowErrorAlert = false

        do {
            try await healthDataRepo.requestAuthorization()
            state = .success
            logService?.trackEvent(event: Event.connectSucceeded)
            onDismiss()
        } catch {
            let errorToHandle: STError = if let stError = error as? STError {
                stError
            } else {
                .unableToCompleteRequest
            }

            logService?.trackEvent(event: Event.connectFailed(error: errorToHandle))
            state = .error
            shouldShowErrorAlert = true
        }
    }

    func onSettingsTapped() {
        logService?.trackEvent(event: Event.settingsTapped)
    }
}

extension HealthKitPermissionPrimingViewModel {
    enum Event: LoggableEvent {
        case viewAppeared
        case viewDisappeared
        case connectTapped
        case connectSucceeded
        case connectFailed(error: STError)
        case settingsTapped

        var eventName: String {
            switch self {
            case .viewAppeared: "HealthKitPriming_View_Appeared"
            case .viewDisappeared: "HealthKitPriming_View_Disappeared"
            case .connectTapped: "HealthKitPriming_Connect_Tapped"
            case .connectSucceeded: "HealthKitPriming_Connect_Succeeded"
            case .connectFailed: "HealthKitPriming_Connect_Failed"
            case .settingsTapped: "HealthKitPriming_Settings_Tapped"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .connectFailed(error):
                ["error": error.localizedDescription]
            default:
                nil
            }
        }

        var type: LogType {
            switch self {
            case .connectFailed: .warning
            case .settingsTapped: .info
            default: .analytic
            }
        }
    }
}
