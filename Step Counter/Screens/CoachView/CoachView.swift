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
                content
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
                if viewModel.state == .loading {
                    thinkingOverlay
                }
            }
        }
        .task {
            viewModel.onAppear()
        }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .initial, .loading:
            placeholderView
        case .success:
            messageView
        case .error:
            errorView
        }
    }

    private var messageView: some View {
        Text(viewModel.coachMessage ?? "")
            .contentTransition(.interpolate)
            .animation(.snappy, value: viewModel.coachMessage)
    }

    private var placeholderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coach Craig is preparing insights.")
                .font(.headline)
            Text("Hang tight while we analyze your recent activity.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var errorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coach Craig hit a snag.")
                .font(.headline)

            Text(viewModel.errorMessage ?? "Please try again in a moment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Try Again", systemImage: "arrow.clockwise") {
                viewModel.onRetryButtonTapped()
            }
            .prominentButton(.pink)
            .disabled(viewModel.state == .loading)
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
