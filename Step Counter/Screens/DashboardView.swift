//
//  DashboardView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import Charts
import SwiftUI

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight

    var id: Self { self }

    var title: String {
        switch self {
        case .steps: "Steps"
        case .weight: "Weight"
        }
    }
    
    var color: Color {
        switch self {
        case .steps: .pink
        case .weight: .indigo
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitData.self) private var healthKitData
    @Environment(HealthKitManager.self) private var healthKitManager
    
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var showPermissionPriming: Bool = false
    @State private var showAlert: Bool = false
    @State private var fetchError: STError = .noData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
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
                .padding()
            }
            .onAppear(perform: fetchHealthData)
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $showPermissionPriming) {
                fetchHealthData()
            } content: {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $showAlert, error: fetchError) { _ in
                // actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(selectedStat.color)
    }
    
    private func fetchHealthData() {
        Task {
            do {
                async let steps = healthKitManager.fetchStepCount()
                async let weightsForLineChart = healthKitManager.fetchWeightsCount(daysBack: 28)
                async let weightsForDiffBarChart = healthKitManager.fetchWeightsCount(daysBack: 29)
                
                healthKitData.stepData = try await steps
                healthKitData.weightData = try await weightsForLineChart
                healthKitData.weightDiffData = try await weightsForDiffBarChart
            } catch STError.authNotDetermined {
                showPermissionPriming = true
            } catch STError.noData {
                fetchError = .noData
                showAlert = true
            } catch {
                fetchError = .unableToCompleteRequest
                showAlert = true
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
