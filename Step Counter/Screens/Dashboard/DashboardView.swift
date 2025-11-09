//
//  DashboardView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

struct DashboardView: View {
    @Namespace private var zoomTransition

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
                        if viewModel.shouldReverseCharts {
                            StepPieChart(
                                chartData: ChartHelper.averageWeekdayCount(for: viewModel.stepData)
                            )
                            
                            StepBarChart(
                                chartData: ChartHelper.convert(data: viewModel.stepData)
                            )
                        } else {
                            StepBarChart(
                                chartData: ChartHelper.convert(data: viewModel.stepData)
                            )
                            
                            StepPieChart(
                                chartData: ChartHelper.averageWeekdayCount(for: viewModel.stepData)
                            )
                        }

                    case .weight:
                        if viewModel.shouldReverseCharts {
                            WeightDiffBarChart(
                                chartData: ChartHelper.averageDailyWeightDiffs(for: viewModel.weightDiffData)
                            )
                            
                            WeightLineChart(
                                chartData: ChartHelper.convert(data: viewModel.weightData)
                            )
                        } else {
                            WeightLineChart(
                                chartData: ChartHelper.convert(data: viewModel.weightData)
                            )

                            WeightDiffBarChart(
                                chartData: ChartHelper.averageDailyWeightDiffs(for: viewModel.weightDiffData)
                            )
                        }
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
                    viewModel: HealthDataListViewModel(
                        healthDataRepo: viewModel.healthDataRepo,
                        healthDataStore: viewModel.healthDataStore
                    ),
                    config: .init(metric: metric)
                )
            }
            .fullScreenCover(isPresented: $viewModel.showPermissionPriming) {
                viewModel.onPermissionSheetDismissed()
            } content: {
                HealthKitPermissionPrimingView(
                    viewModel: HealthKitPermissionPrimingViewModel(
                        healthDataRepo: viewModel.healthDataRepo
                    )
                )
            }
            .sheet(isPresented: $viewModel.showCoachSheet) {
                if #available(iOS 26.0, *) {
                    CoachView(viewModel: CoachViewModel(dataIntelligenceRepo: viewModel.dataIntelligenceRepo))
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationContentInteraction(.scrolls)
                        .navigationTransition(.zoom(sourceID: "coachView", in: zoomTransition))
                }
            }
            .alert(isPresented: $viewModel.shouldShowAlert, error: viewModel.fetchError) { _ in
                // actions
            } message: { error in
                Text(error.failureReason)
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.dataIntelligenceRepo.isAvailable {
                            Button("Analyze data", systemImage: "apple.intelligence") {
                                viewModel.showCoachSheet = true
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

#Preview("Regular") {
    DashboardView(
        viewModel: DashboardViewModel(
            healthDataRepo: MockHealthDataRepository(steps: MockData.steps, weights: MockData.weights),
            healthDataStore: HealthDataStore(),
            dataIntelligenceRepo: MockIntelligenceRepository(),
            abTestRepo: ABTestRepository(service: MockABTestService())
        )
    )
}

#Preview("Regular - ABTest (Weight default)") {
    DashboardView(
        viewModel: DashboardViewModel(
            healthDataRepo: MockHealthDataRepository(steps: MockData.steps, weights: MockData.weights),
            healthDataStore: HealthDataStore(),
            dataIntelligenceRepo: MockIntelligenceRepository(),
            abTestRepo: ABTestRepository(service: MockABTestService(appOpenOnHealthMetricTest: .weight))
        )
    )
}

#Preview("Regular - ABTest (Reverse Charts)") {
    DashboardView(
        viewModel: DashboardViewModel(
            healthDataRepo: MockHealthDataRepository(steps: MockData.steps, weights: MockData.weights),
            healthDataStore: HealthDataStore(),
            dataIntelligenceRepo: MockIntelligenceRepository(),
            abTestRepo: ABTestRepository(service: MockABTestService(areChartsReversedTest: true))
        )
    )
}

#Preview("No Data") {
    DashboardView(
        viewModel: DashboardViewModel(
            healthDataRepo: MockHealthDataRepository(),
            healthDataStore: HealthDataStore(),
            dataIntelligenceRepo: MockIntelligenceRepository(),
            abTestRepo: ABTestRepository(service: MockABTestService())
        )
    )
}

#Preview("Not Authorized") {
    DashboardView(
        viewModel: DashboardViewModel(
            healthDataRepo: MockHealthDataRepository(authorizationState: .denied(STError.authNotDetermined)),
            healthDataStore: HealthDataStore(),
            dataIntelligenceRepo: MockIntelligenceRepository(),
            abTestRepo: ABTestRepository(service: MockABTestService())
        )
    )
}
