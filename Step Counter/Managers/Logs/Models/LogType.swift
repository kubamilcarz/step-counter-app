//
//  LogType.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/11/2025.
//

import Foundation
import OSLog

enum LogType {
    /// Use 'info' for informative tasks. These are not considered anylytics, issues, or errors.
    case info

    /// Default type for analytics
    case analytic

    /// Issues or errors that should not occur, but will not negatively affect the user experience
    case warning

    /// Issues or errors that negatively affect user experience
    case severe

    var emoji: String {
        switch self {
        case .info: "ℹ️"
        case .analytic: "📊"
        case .warning: "⚠️"
        case .severe: "🚨"
        }
    }

    var OSLogType: OSLogType {
        switch self {
        case .info: .info
        case .analytic: .default
        case .warning: .error
        case .severe: .fault
        }
    }
}
