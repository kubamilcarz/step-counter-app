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
                        StepBarChart(
                            chartData: ChartHelper.convert(data: viewModel.stepData)
                        )

                        StepPieChart(
                            chartData: ChartHelper.averageWeekdayCount(for: viewModel.stepData)
                        )

                    case .weight:
                        WeightLineChart(
                            chartData: ChartHelper.convert(data: viewModel.weightData)
                        )

                        WeightDiffBarChart(
                            chartData: ChartHelper.averageDailyWeightDiffs(for: viewModel.weightDiffData)
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
                    viewModel: HealthDataListViewModel(
                        healthDataRepo: viewModel.healthDataRepo,
                        healthDataStore: viewModel.healthDataStore
                    ),
                    config: .init(metric: metric)
                )
            }
            .fullScreenCover(isPresented: $viewModel.shouldShowPermissionPriming) {
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

#Preview {
    DashboardView(
        viewModel: DashboardViewModel(
            healthDataRepo: MockHealthDataRepository(),
            healthDataStore: HealthDataStore(),
            dataIntelligenceRepo: MockIntelligenceRepository()
        )
    )
}
