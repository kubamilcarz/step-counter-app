//
//  ViewState.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import Foundation

/// This enum models the common lifecycle of loading data and presenting results.
///
/// - initial: The default state before any work has started. Use this for placeholder or empty UI.
/// - loading: A transient state indicating work is currently in progress. Use to display activity indicators.
/// - success: The state indicating the operation completed successfully and the view can display results.
/// - error: The state indicating the operation failed. Consider augmenting this state with associated
///   error information if you need to surface diagnostic details to the UI.
///
/// Example:
/// ```swift
/// switch viewState {
/// case .initial: showPlaceholder()
/// case .loading: showSpinner()
/// case .success: showContent()
/// case .error: showErrorMessage()
/// }
/// ```
enum ViewState {
    case initial
    case loading
    case success
    case error
}
