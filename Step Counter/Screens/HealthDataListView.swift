//
//  HealthDataListView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitData.self) private var healthKitData
    @Environment(HealthKitManager.self) private var healthKitManager
    @Namespace private var zoomTransition

    var metric: HealthMetricContext

    @State private var showAddData = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd = ""

    @State private var showAlert = false
    @State private var writeError: STError = .noData

    var listData: [HealthMetric] {
        metric == .steps ? healthKitData.stepData : healthKitData.weightData
    }

    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 2)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
            .accessibilityElement(children: .combine)
        }
        .scrollContentBackground(.hidden)
        .gradientBackground(using: metric.color)
        .navigationTitle(metric.title)
        .overlay {
            if listData.isEmpty {
                ContentUnavailableView(
                    "No \(metric.title) to Display",
                    systemImage: metric == .steps ? "figure.walk" : "figure"
                )
            }
        }
        .sheet(isPresented: $showAddData) {
            if #available(iOS 26.0, *) {
                addDataView
                    .presentationDetents([.fraction(0.4)])
                    .navigationTransition(.zoom(sourceID: "addData", in: zoomTransition))
            } else {
                addDataView
                    .presentationDetents([.fraction(0.4)])
            }
        }
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Data", systemImage: "plus") {
                        showAddData = true
                    }
                    .buttonStyle(.glassProminent)
                    .tint(metric.color)
                }
                .matchedTransitionSource(id: "addData", in: zoomTransition)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        showAddData = true
                    }
                }
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
            .scrollContentBackground(.hidden)
            .alert(isPresented: $showAlert, error: writeError) { writeError in
                switch writeError {
                case .sharingDenied:
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }

                    Button("Cancel", role: .cancel) {}

                default:
                    EmptyView()
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button("Add Data", systemImage: "checkmark", role: .confirm) {
                            addDataToHealthKit()
                        }
                        .tint(metric.color)
                    } else {
                        Button("Add Data") {
                            addDataToHealthKit()
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button("Dismiss", systemImage: "xmark", role: .close) {
                            showAddData = false
                        }
                        .tint(metric.color)
                    } else {
                        Button("Dismiss") {
                            showAddData = false
                        }
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
                    healthKitData.stepData = try await healthKitManager.fetchStepCount()
                } else {
                    try await healthKitManager.addWeightData(for: addDataDate, value: value)
                    async let weightsforLineChart = healthKitManager.fetchWeightsCount(daysBack: 28)
                    async let weightsForDiffChart = healthKitManager.fetchWeightsCount(daysBack: 29)

                    healthKitData.weightData = try await weightsforLineChart
                    healthKitData.weightDiffData = try await weightsForDiffChart
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
    .environment(HealthKitData())
}

#Preview("Weight List") {
    NavigationStack {
        HealthDataListView(
            metric: .weight
        )
    }
    .environment(HealthKitManager())
    .environment(HealthKitData())
}
