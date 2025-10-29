//
//  DashboardView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

struct DashboardView: View {
    @Namespace private var zoomTransition

    @Environment(HealthKitData.self) private var healthKitData
    @Environment(HealthKitManager.self) private var healthKitManager

    @State var viewModel: DashboardViewModel

    var navbarTint: Color {
        if #available(iOS 26.0, *) {
            .primary
        } else {
            viewModel.selectedMetric.color
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Metric", selection: $viewModel.selectedMetric) {
                        ForEach(HealthMetricContext.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch viewModel.selectedMetric {
                    case .steps:
                        StepBarChart(
                            chartData: ChartHelper.convert(data: healthKitData.stepData)
                        )

                        StepPieChart(
                            chartData: ChartHelper.averageWeekdayCount(for: healthKitData.stepData)
                        )

                    case .weight:
                        WeightLineChart(
                            chartData: ChartHelper.convert(data: healthKitData.weightData)
                        )

                        WeightDiffBarChart(
                            chartData: ChartHelper.averageDailyWeightDiffs(for: healthKitData.weightDiffData)
                        )
                    }
                }
                .padding(16)
            }
            .gradientBackground(using: viewModel.selectedMetric.color)
            .onAppear(perform: viewModel.onAppear)
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(
                    viewModel: HealthDataListViewModel(healthKitData: healthKitData),
                    config: .init(metric: metric)
                )
            }
            .fullScreenCover(isPresented: $viewModel.shouldShowPermissionPriming) {
                viewModel.onPermissionSheetDismissed()
            } content: {
                HealthKitPermissionPrimingView(
                    viewModel: HealthKitPermissionPrimingViewModel(
                        healthKitManager: healthKitManager
                    )
                )
            }
            .backportCoachSheet(isPresented: $viewModel.shouldShowCoachSheet, namespace: zoomTransition)
            .alert(isPresented: $viewModel.shouldShowAlert, error: viewModel.fetchError) { _ in
                // actions
            } message: { error in
                Text(error.failureReason)
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        if DataAnalyzer.shared.isAvailable {
                            Button("Analyze data", systemImage: "apple.intelligence") {
                                viewModel.shouldShowCoachSheet = true
                            }
                        }
                    }
                    .matchedTransitionSource(id: "coachView", in: zoomTransition)
                }
            }
        }
        .tint(navbarTint)
    }
}

#Preview {
    let healthKitManager = HealthKitManager()
    let healthKitData = HealthKitData()

    return DashboardView(
        viewModel: DashboardViewModel(
            healthKitManager: healthKitManager,
            healthKitData: healthKitData
        )
    )
    .environment(healthKitManager)
    .environment(healthKitData)
}
