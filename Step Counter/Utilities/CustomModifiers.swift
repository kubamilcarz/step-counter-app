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

struct BackportCoachSheet: ViewModifier {
    @Binding var isPresented: Bool
    var namespace: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .sheet(isPresented: $isPresented) {
                    DataAnalyzer.shared.coachMessage = ""
                } content: {
                    CoachView(viewModel: CoachViewModel(analyzer: DataAnalyzer.shared))
                        .presentationDetents([.fraction(0.8)])
                        .navigationTransition(.zoom(sourceID: "coachView", in: namespace))
                }
        } else {
            content
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

    func backportCoachSheet(isPresented: Binding<Bool>, namespace: Namespace.ID) -> some View {
        modifier(BackportCoachSheet(isPresented: isPresented, namespace: namespace))
    }
}
