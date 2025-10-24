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
    
    /// Short error title for alerts.
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Access to Health Data"
        case .noData:
            "No Write Access"
        case .unableToCompleteRequest:
            "Unable to Complete Request"
        case .sharingDenied(_):
            "No Write Access"
        case .invalidValue:
            "Invalid Value"
        }
    }
    
    /// Detailed error message with recovery steps.
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Settings > Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistics."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time.\n\nPlease try again later or contact support."
        case let .sharingDenied(quantityType):
            "You have denied access to upload your \(quantityType) data.\n\nYou can change this in Settings > Health > Data Access & Devices."
        case .invalidValue:
            "Must be a numeric value with a maximum of one decimal place."
        }
    }
}
