//
//  CustomModifiers.swift
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
}
