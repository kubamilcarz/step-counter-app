//
//  HealthMetricContext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 29/10/2025.
//

import SwiftUI

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
