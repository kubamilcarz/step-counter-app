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
            HStack {
                Text(data.date, format: .dateTime.month().day().year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 2)))
            }
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

                HStack {
                    Text(metric.title)
                    Spacer()
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
                        guard let value = Double(valueToAdd) else {
                            writeError = .invalidValue
                            showAlert = true
                            valueToAdd = ""
                            return
                        }
                        
                        Task {
                            if metric == .steps {
                                do {
                                    try await healthKitManager.addStepData(for: addDataDate, value: value)
                                    try await healthKitManager.fetchStepCount()
                                    
                                    showAddData = false
                                } catch let STError.sharingDenied(quantityType: type) {
                                    writeError = .sharingDenied(quantityType: type)
                                    showAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    showAlert = true
                                }
                            } else {
                                do {
                                    try await healthKitManager.addWeightData(for: addDataDate, value: value)
                                    try await healthKitManager.fetchWeightsCount()
                                    try await healthKitManager.fetchWeightsForDifferentials()
                                    
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
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        showAddData = false
                    }
                }
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
