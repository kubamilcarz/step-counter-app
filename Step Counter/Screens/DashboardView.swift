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
        case .steps: return "Steps"
        case .weight: return "Weight"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var showPermissionPriming: Bool = false
    @State private var showAlert: Bool = false
    @State private var fetchError: STError = .noData

    var isSteps: Bool { selectedStat == .steps }

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
                            selectedStat: selectedStat,
                            chartData: healthKitManager.stepData
                        )
                        
                        StepPieChart(
                            chartData: ChartMath.averageWeekdayCount(for: healthKitManager.stepData)
                        )
                    case .weight:
                        WeightLineChart(
                            selectedStat: selectedStat,
                            chartData: healthKitManager.weightData
                        )
                        
                        WeightDiffBarChart(
                            chartData: ChartMath.averageDailyWeightDiffs(for: healthKitManager.weightDiffData)
                        )
                    }
                }
                .padding()
            }
            .task {
                do {
                    try await healthKitManager.fetchStepCount()
                    try await healthKitManager.fetchWeightsCount()
                    try await healthKitManager.fetchWeightsForDifferentials()
                    
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
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $showPermissionPriming) {
                // fetch health data
            } content: {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $showAlert, error: fetchError) { _ in
                // actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
