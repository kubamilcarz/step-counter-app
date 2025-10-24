//
//  HealthKitPermissionPrimingView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import HealthKitUI
import SwiftUI

struct HealthKitPermissionPrimingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var showHealthKitPermissions: Bool = false

    private let description = """
    This app displays your step and weight data in interactive charts.

    You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
    """

    var body: some View {
        VStack(alignment: .leading, spacing: 130) {
            VStack(alignment: .leading, spacing: 10) {
                Image(.appleHealth)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 10)
                    .padding(.bottom, 12)

                Text("Apple Health Integration")
                    .font(.title2)
                    .bold()

                Text(description)
                    .foregroundStyle(.secondary)
            }

            Button("Connect Apple Health") {
                showHealthKitPermissions = true
            }
            .prominentButton(.pink)
            .tint(.pink)
        }
        .padding(30)
        .healthDataAccessRequest(
            store: healthKitManager.store,
            shareTypes: healthKitManager.types,
            readTypes: healthKitManager.types,
            trigger: showHealthKitPermissions
        ) { result in
            switch result {
            case .success:
                Task { @MainActor in dismiss() }
            case .failure:
                // more code to come
                Task { @MainActor in dismiss() }
            }
        }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
