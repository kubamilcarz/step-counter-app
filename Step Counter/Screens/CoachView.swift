//
//  CoachView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import SwiftUI

@available(iOS 26.0, *)
struct CoachView: View {
    @Environment(\.dismiss) private var dismiss
    let analyzer = DataAnalyzer.shared

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(.coach)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .scaledToFill()
                    .clipShape(.circle)

                Text("Coach Craig")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("OK", systemImage: "checkmark", role: .confirm) {
                    dismiss()
                }
                .labelStyle(.iconOnly)
                .padding(12)
                .clipShape(.circle)
                .glassEffect(.regular.tint(.pink).interactive())
            }
            .padding([.horizontal, .top])

            ScrollView {
                Text(analyzer.coachMessage ?? "")
                    .contentTransition(.interpolate)
                    .animation(.snappy, value: analyzer.coachMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .overlay {
            if analyzer.isThinking {
                VStack(spacing: 16) {
                    Image(systemName: "apple.intelligence")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .symbolEffect(.pulse, options: .repeat(.continuous))

                    Text("Thinking...")
                        .font(.callout)
                }
                .foregroundStyle(.secondary)
                .frame(minWidth: 200)
            }
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    CoachView()
}
