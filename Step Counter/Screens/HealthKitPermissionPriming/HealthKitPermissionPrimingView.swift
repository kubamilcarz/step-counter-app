//
//  HealthKitPermissionPrimingView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import Observation
import SwiftUI

struct HealthKitPermissionPrimingView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: HealthKitPermissionPrimingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()

            Image(.appleHealth)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .shadow(color: .gray.opacity(0.3), radius: 10)
                .padding(.bottom, 12)

            Text("Apple Health Integration")
                .font(.title2)
                .bold()

            Text(viewModel.description)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(30)
        .safeAreaInset(edge: .bottom) {
            Button {
                Task {
                    await viewModel.onConnectButtonTapped(onDismiss: {
                        dismiss()
                    })
                }
            } label: {
                Text("Connect Apple Health")
                    .padding(8)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .prominentButton(.pink)
            .tint(.pink)
            .disabled(viewModel.state == .loading)
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
        }
        .overlay {
            if viewModel.state == .loading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert(
            "No Read and Write Access",
            isPresented: $viewModel.shouldShowErrorAlert,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text(
                    "To use Step Counter with Apple Health, please enable read and write access for step count and weight data in Settings > Health > Data Access & Devices > Step Counter."
                )
            }
        )
    }
}

#Preview {
    HealthKitPermissionPrimingView(
        viewModel: HealthKitPermissionPrimingViewModel(
            healthKitManager: HealthKitManager()
        )
    )
}
