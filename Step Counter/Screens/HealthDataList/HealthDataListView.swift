//
//  HealthDataListView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

struct HealthDataListView: View {
    @Namespace private var zoomTransition

    @State var viewModel: HealthDataListViewModel

    var body: some View {
        List(viewModel.listData) { data in
            LabeledContent {
                Text(
                    data.value,
                    format: .number.precision(.fractionLength(viewModel.metric == .steps ? 0 : 2))
                )
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
            .accessibilityElement(children: .combine)
        }
        .scrollContentBackground(.hidden)
        .gradientBackground(using: viewModel.metric.color)
        .navigationTitle(viewModel.metric.title)
        .overlay {
            if viewModel.state == .loading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .overlay {
            if viewModel.listData.isEmpty {
                ContentUnavailableView(
                    "No \(viewModel.metric.title) to Display",
                    systemImage: viewModel.metric == .steps ? "figure.walk" : "figure"
                )
            }
        }
        .sheet(isPresented: $viewModel.showAddData) {
            if #available(iOS 26.0, *) {
                addDataView
                    .presentationDetents([.fraction(0.4)])
                    .navigationTransition(.zoom(sourceID: "addData", in: zoomTransition))
            } else {
                addDataView
                    .presentationDetents([.fraction(0.4)])
            }
        }
        .alert(isPresented: $viewModel.showAlert, error: viewModel.writeError) { writeError in
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
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Data", systemImage: "plus") {
                        viewModel.presentAddData()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(viewModel.metric.color)
                    .disabled(viewModel.state == .loading)
                }
                .matchedTransitionSource(id: "addData", in: zoomTransition)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        viewModel.presentAddData()
                    }
                    .disabled(viewModel.state == .loading)
                }
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    private var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $viewModel.addDataDate, displayedComponents: .date)

                LabeledContent(viewModel.metric.title) {
                    TextField("Value", text: $viewModel.valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(viewModel.metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(viewModel.metric.title)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button("Add Data", systemImage: "checkmark", role: .confirm) {
                            viewModel.addData()
                        }
                        .tint(viewModel.metric.color)
                        .disabled(viewModel.state == .loading)
                    } else {
                        Button("Add Data") {
                            viewModel.addData()
                        }
                        .disabled(viewModel.state == .loading)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button("Dismiss", systemImage: "xmark", role: .close) {
                            viewModel.dismissAddData()
                        }
                        .tint(viewModel.metric.color)
                        .disabled(viewModel.state == .loading)
                    } else {
                        Button("Dismiss") {
                            viewModel.dismissAddData()
                        }
                        .disabled(viewModel.state == .loading)
                    }
                }
            }
        }
    }
}

#Preview("Steps List") {
    NavigationStack {
        HealthDataListView(
            viewModel: HealthDataListViewModel(
                metric: .steps,
                healthKitManager: HealthKitManager(),
                healthKitData: HealthKitData()
            )
        )
    }
}

#Preview("Weight List") {
    NavigationStack {
        HealthDataListView(
            viewModel: HealthDataListViewModel(
                metric: .weight,
                healthKitManager: HealthKitManager(),
                healthKitData: HealthKitData()
            )
        )
    }
}
