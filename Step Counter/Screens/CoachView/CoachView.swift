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

    @State var viewModel: CoachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(viewModel.coachMessage ?? "")
                    .contentTransition(.interpolate)
                    .animation(.snappy, value: viewModel.coachMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 10) {
                        Image(.coach)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(.circle)

                        Text("Coach Craig")
                    }
                    .frame(minWidth: 150, maxWidth: .infinity)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK", systemImage: "checkmark", role: .confirm) {
                        viewModel.onCloseButtonTapped {
                            dismiss()
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isThinking {
                    thinkingOverlay
                }
            }
        }
    }

    private var thinkingOverlay: some View {
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

@available(iOS 26.0, *)
#Preview {
    CoachView(viewModel: CoachViewModel(analyzer: DataAnalyzer.shared))
}
