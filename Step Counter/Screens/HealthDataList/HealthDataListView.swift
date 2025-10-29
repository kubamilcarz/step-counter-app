//
//  HealthDataListView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import SwiftUI

struct HealthDataListView: View {
    @Namespace private var zoomTransition
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(HealthKitData.self) private var healthKitData

    @State var viewModel: HealthDataListViewModel
    let config: HealthDataListViewConfig
    
    var body: some View {
        List(viewModel.listData) { data in
            LabeledContent {
                Text(
                    data.value,
                    format: .number.precision(.fractionLength(config.metric == .steps ? 0 : 2))
                )
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
            .accessibilityElement(children: .combine)
        }
        .scrollContentBackground(.hidden)
        .gradientBackground(using: config.metric.color)
        .navigationTitle(config.metric.title)
        .overlay {
            if viewModel.state == .loading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .overlay {
            if viewModel.listData.isEmpty {
                ContentUnavailableView(
                    "No \(config.metric.title) to Display",
                    systemImage: config.metric == .steps ? "figure.walk" : "figure"
                )
            }
        }
        .sheet(isPresented: $viewModel.showAddDataSheet) {
            if #available(iOS 26.0, *) {
                AddDataView(
                    viewModel: AddDataViewModel(
                        healthKitManager: healthKitManager,
                        healthKitData: healthKitData
                    ),
                    config: AddDataViewConfig(metric: config.metric, onCompletion: viewModel.onAddSuccess)
                )
                .presentationDetents([.fraction(0.4)])
                .navigationTransition(.zoom(sourceID: "addData", in: zoomTransition))
            } else {
                AddDataView(
                    viewModel: AddDataViewModel(
                        healthKitManager: healthKitManager,
                        healthKitData: healthKitData
                    ),
                    config: AddDataViewConfig(metric: config.metric, onCompletion: viewModel.onAddSuccess)
                )
                .presentationDetents([.fraction(0.4)])
            }
        }
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Data", systemImage: "plus") {
                        viewModel.onAddButtonTapped()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(viewModel.metric.color)
                    .disabled(viewModel.state == .loading)
                }
                .matchedTransitionSource(id: "addData", in: zoomTransition)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        viewModel.onAddButtonTapped()
                    }
                    .disabled(viewModel.state == .loading)
                }
            }
        }
        .onAppear { viewModel.onAppear(config: config) }
    }
}

#Preview("Steps List") {
    NavigationStack {
        HealthDataListView(
            viewModel: HealthDataListViewModel(
                healthKitManager: HealthKitManager(),
                healthKitData: HealthKitData()
            ),
            config: .init(metric: .steps)
        )
    }
}

#Preview("Weight List") {
    NavigationStack {
        HealthDataListView(
            viewModel: HealthDataListViewModel(
                healthKitManager: HealthKitManager(),
                healthKitData: HealthKitData()
            ),
            config: .init(metric: .weight)
        )
    }
}
