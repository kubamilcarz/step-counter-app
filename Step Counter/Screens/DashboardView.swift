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
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming: Bool = false

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
                    
                    StepBarChart(
                        selectedStat: selectedStat,
                        chartData: healthKitManager.stepData
                    )
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Label("Averages", systemImage: "calendar")
                                .font(.title3.bold())
                                .foregroundStyle(.pink)
                            
                            Text("Last 28 days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 250)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                }
                .padding()
            }
            .task {
                await healthKitManager.fetchStepCount()
                showPermissionPriming = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $showPermissionPriming) {
                // fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeenView: $hasSeenPermissionPriming)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
}
