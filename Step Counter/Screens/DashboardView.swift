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
                            chartData: ChartHelper.convert(data: healthKitManager.stepData)
                        )
                        
                        StepPieChart(
                            chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData)
                        )
                    case .weight:
                        WeightLineChart(
                            chartData: ChartHelper.convert(data: healthKitManager.weightData)
                        )
                        
                        WeightDiffBarChart(
                            chartData: ChartMath.averageDailyWeightDiffs(for: healthKitManager.weightDiffData)
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
                
                healthKitManager.stepData = try await steps
                healthKitManager.weightData = try await weightsForLineChart
                healthKitManager.weightDiffData = try await weightsForDiffBarChart
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
