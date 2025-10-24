//
//  HealthDataListView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    
    var metric: HealthMetricContext
    
    @State private var showAddData: Bool = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    @State private var showAlert: Bool = false
    @State private var writeError: STError = .noData
        
    var listData: [HealthMetric] {
        metric == .steps ? healthKitManager.stepData : healthKitManager.weightData
    }

    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 2)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .accessibilityElement(children: .combine)
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $showAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                showAddData = true
            }
        }
    }

    private var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)

                LabeledContent(metric.title) {
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .alert(isPresented: $showAlert, error: writeError) { writeError in
                switch writeError {
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    
                    Button("Cancel", role: .cancel) { }
                default:
                    EmptyView()
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        addDataToHealthKit()
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        showAddData = false
                    }
                }
            }
        }
    }
        
    private func addDataToHealthKit() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            showAlert = true
            valueToAdd = ""
            return
        }
        
        Task {
            do {
                if metric == .steps {
                    try await healthKitManager.addStepData(for: addDataDate, value: value)
                    healthKitManager.stepData = try await healthKitManager.fetchStepCount()
                } else {
                    try await healthKitManager.addWeightData(for: addDataDate, value: value)
                    async let weightsforLineChart = healthKitManager.fetchWeightsCount(daysBack: 28)
                    async let weightsForDiffChart = healthKitManager.fetchWeightsCount(daysBack: 29)
                    
                    healthKitManager.weightData = try await weightsforLineChart
                    healthKitManager.weightDiffData = try await weightsForDiffChart
                }
                
                showAddData = false
            } catch let STError.sharingDenied(quantityType: type) {
                writeError = .sharingDenied(quantityType: type)
                showAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                showAlert = true
            }
        }
    }
}

#Preview("Steps List") {
    NavigationStack {
        HealthDataListView(
            metric: .steps
        )
    }
    .environment(HealthKitManager())
}

#Preview("Weight List") {
    NavigationStack {
        HealthDataListView(
            metric: .weight
        )
    }
    .environment(HealthKitManager())
}
