//
//  View+Ext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import SwiftUI

struct ProminentButton: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(color)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .tint(color)
        }
    }
}

extension View {
    func prominentButton(_ color: Color) -> some View {
        modifier(ProminentButton(color: color))
    }

    func gradientBackground(using color: Color) -> some View {
        background(LinearGradient(
            colors: [color.opacity(0.25), color.opacity(0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
}
