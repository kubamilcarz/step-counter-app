//
//  STError.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import Foundation

/// Custom errors for HealthKit operations with user-friendly messages.
enum STError: LocalizedError {
    /// HealthKit authorization not yet requested.
    case authNotDetermined

    /// No data available for the requested metric/period.
    case noData

    /// General HealthKit operation failure.
    case unableToCompleteRequest

    /// User denied write access for a specific metric.
    case sharingDenied(quantityType: String)

    /// Input value failed validation.
    case invalidValue

    case intelligenceUnavailable

    /// Short error title for alerts.
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            String(localized: "Need Access to Health Data")
        case .noData:
            String(localized: "No Write Access")
        case .unableToCompleteRequest:
            String(localized: "Unable to Complete Request")
        case .sharingDenied:
            String(localized: "No Write Access")
        case .invalidValue:
            String(localized: "Invalid Value")
        case .intelligenceUnavailable:
            String(localized: "Data Intelligence is not Available")
        }
    }

    /// Detailed error message with recovery steps.
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            String(
                localized: "You have not given access to your Health data. Please go to Settings > Health > Data Access & Devices."
            )

        case .noData:
            String(localized: "There is no data for this Health statistics.")

        case .unableToCompleteRequest:
            String(
                localized: "We are unable to complete your request at this time.\n\nPlease try again later or contact support."
            )

        case let .sharingDenied(quantityType):
            String(
                localized: "You have denied access to upload your \(quantityType) data.\n\nYou can change this in Settings > Health > Data Access & Devices."
            )

        case .invalidValue:
            String(localized: "Must be a numeric value with a maximum of one decimal place.")

        case .intelligenceUnavailable:
            String(localized: "This feature is currently not available on this device.")
        }
    }
}
