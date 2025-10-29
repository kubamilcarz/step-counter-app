//
//  HealthMetricContext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import SwiftUI

/// Provides the available metric types and UI metadata (localized title and display color)
/// for each metric. Conforms to `CaseIterable` to enumerate all metrics and `Identifiable`
/// where `id` returns the enum case itself.
///
/// - Cases:
///   - steps: Represents the user's step count metric.
///   - weight: Represents the user's weight metric.
///
/// - Properties:
///   - id: The identity of the metric (returns the enum case).
///   - title: A localized, user-facing title for the metric.
///   - color: A `Color` used to visually distinguish the metric in the UI.
enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight

    var id: Self { self }

    var title: String {
        switch self {
        case .steps:
            String(localized: "Steps")
        case .weight:
            String(localized: "Weight")
        }
    }

    var color: Color {
        switch self {
        case .steps: .pink
        case .weight: .indigo
        }
    }
}
