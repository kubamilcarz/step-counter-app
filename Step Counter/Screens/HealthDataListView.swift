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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            if metric == .steps {
                                await healthKitManager.addStepData(for: addDataDate, value: Double(valueToAdd)!)
                                await healthKitManager.fetchStepCount()
                            } else {
                                await healthKitManager.addWeightData(for: addDataDate, value: Double(valueToAdd)!)
                                await healthKitManager.fetchWeightsCount()
                                await healthKitManager.fetchWeightsForDifferentials()
                            }
                            
                            showAddData = false
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
