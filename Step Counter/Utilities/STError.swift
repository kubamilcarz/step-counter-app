//
//  STError.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import Foundation

/// Custom error types for Step Counter app operations, particularly HealthKit interactions.
///
/// This enumeration defines all possible error states that can occur during the app's
/// operation, with a focus on HealthKit authorization and data access issues. Each error
/// provides localized, user-friendly descriptions and actionable failure reasons.
///
/// ## Error Categories
/// - **Authorization Errors**: Issues with HealthKit permissions
/// - **Data Errors**: Problems with data availability or validity
/// - **Request Errors**: General operation failures
///
/// ## Localization
/// Conforms to `LocalizedError` protocol to provide:
/// - User-facing error titles (`errorDescription`)
/// - Detailed explanations and solutions (`failureReason`)
///
/// ## Usage Pattern
/// ```swift
/// do {
///     try await healthManager.addStepData(for: date, value: steps)
/// } catch let error as STError {
///     // Display error.errorDescription and error.failureReason to user
///     alertTitle = error.errorDescription ?? "Error"
///     alertMessage = error.failureReason
/// }
/// ```
///
/// - Note: All errors provide user-actionable messages, including guidance to Settings.
/// - SeeAlso: `HealthKitManager` for methods that throw these errors.
enum STError: LocalizedError {
    
    // MARK: - Error Cases
    
    /// HealthKit authorization has not been requested or determined.
    ///
    /// This error occurs when attempting to access HealthKit data before requesting
    /// user permission. It indicates that the app needs to present the HealthKit
    /// authorization prompt.
    ///
    /// **When Thrown:**
    /// - Calling `fetchStepCount()` before authorization
    /// - Calling `fetchWeightsCount()` before authorization
    /// - Calling `addStepData()` before authorization
    /// - Calling `addWeightData()` before authorization
    ///
    /// **User Action:**
    /// User should be directed to grant HealthKit permissions through the system prompt.
    ///
    /// **Recovery:**
    /// Call `HKHealthStore.requestAuthorization(toShare:read:)` to prompt for permissions.
    case authNotDetermined
    
    /// No health data is available for the requested metric.
    ///
    /// This error indicates that HealthKit returned no data for the queried time period
    /// and metric type. This is different from having zero values—it means the data
    /// simply doesn't exist in the HealthKit store.
    ///
    /// **When Thrown:**
    /// - No step count data exists for the requested date range
    /// - No weight measurements exist for the requested date range
    /// - User has never recorded the requested metric type
    ///
    /// **Common Causes:**
    /// - Fresh device with no historical data
    /// - User hasn't worn Apple Watch or used fitness apps
    /// - Querying dates before the user owned their device
    ///
    /// **Recovery:**
    /// Inform user that no data exists and optionally offer to add manual entries.
    case noData
    
    /// The HealthKit operation failed for an unknown or general reason.
    ///
    /// This is a catch-all error for HealthKit operations that fail for reasons
    /// not covered by more specific error cases. It could indicate network issues,
    /// database problems, or other system-level failures.
    ///
    /// **When Thrown:**
    /// - HealthKit database is unavailable
    /// - System resources are exhausted
    /// - Unexpected errors during save or query operations
    ///
    /// **Recovery:**
    /// User should try the operation again later. If the problem persists,
    /// they should contact support or check system status.
    case unableToCompleteRequest
    
    /// User has explicitly denied write access for a specific health metric.
    ///
    /// This error occurs when attempting to save data to HealthKit for a metric
    /// type that the user has denied write permission for. The associated value
    /// contains the human-readable name of the denied metric.
    ///
    /// **When Thrown:**
    /// - Calling `addStepData()` when step count write access is denied
    /// - Calling `addWeightData()` when body mass write access is denied
    ///
    /// **Associated Value:**
    /// - `quantityType`: Human-readable name (e.g., "step count", "weight")
    ///
    /// **User Action:**
    /// User must go to Settings > Health > Data Access & Devices to enable write
    /// permissions for the app.
    ///
    /// **Example:**
    /// ```swift
    /// throw STError.sharingDenied(quantityType: "step count")
    /// // Message: "You have denied access to upload your step count data."
    /// ```
    case sharingDenied(quantityType: String)
    
    /// The provided input value is invalid or doesn't meet validation requirements.
    ///
    /// This error indicates that user input failed validation rules, such as
    /// containing non-numeric characters, having too many decimal places, or
    /// being outside acceptable ranges.
    ///
    /// **When Thrown:**
    /// - User enters text in a numeric field
    /// - Value has more than one decimal place (e.g., "123.456")
    /// - Value is negative when positive is required
    /// - Value exceeds reasonable bounds for the metric
    ///
    /// **Validation Rules:**
    /// - Must be numeric (Double-parseable)
    /// - Maximum one decimal place
    /// - Must be positive for most health metrics
    ///
    /// **Recovery:**
    /// User should correct their input to meet validation requirements.
    case invalidValue
    
    // MARK: - LocalizedError Conformance
    
    /// User-facing error title displayed in alerts and error UI.
    ///
    /// Provides a brief, localized description of the error suitable for display
    /// as an alert title or error heading. These are intentionally concise.
    ///
    /// - Returns: A short error description string.
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
    
    /// Detailed explanation of why the error occurred and how to resolve it.
    ///
    /// Provides comprehensive, user-friendly explanations that include:
    /// - Why the error happened
    /// - What the user can do to fix it
    /// - Specific navigation paths to Settings when applicable
    ///
    /// These messages are designed to be displayed in alert bodies or error
    /// detail sections, giving users clear guidance on resolving the issue.
    ///
    /// ## Message Design
    /// - **Actionable**: Tells user exactly what to do
    /// - **Specific**: Includes exact Settings paths when relevant
    /// - **Non-technical**: Avoids jargon and technical details
    ///
    /// - Returns: A detailed failure reason string with recovery guidance.
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
