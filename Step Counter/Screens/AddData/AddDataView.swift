//
//  AddDataView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 01/11/2025.
//

import SwiftUI

struct AddDataView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: AddDataViewModel
    let config: AddDataViewConfig

    var body: some View {
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
            .overlay {
                if viewModel.state == .loading {
                    ProgressView()
                        .progressViewStyle(.circular)
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
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button("Add Data", systemImage: "checkmark", role: .confirm) {
                            viewModel.addData {
                                config.onCompletion()
                                dismiss()
                            }
                        }
                        .tint(viewModel.metric.color)
                        .disabled(viewModel.state == .loading)
                    } else {
                        Button("Add Data") {
                            viewModel.addData {
                                config.onCompletion()
                                dismiss()
                            }
                        }
                        .disabled(viewModel.state == .loading)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button("Dismiss", systemImage: "xmark", role: .close) {
                            viewModel.onCancel {
                                dismiss()
                            }
                        }
                        .disabled(viewModel.state == .loading)
                    } else {
                        Button("Dismiss") {
                            viewModel.onCancel {
                                dismiss()
                            }
                        }
                        .disabled(viewModel.state == .loading)
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.state == .loading)
        }
        .onAppear {
            viewModel.onViewAppear(config: config)
        }
    }
}

#Preview {
    AddDataView(
        viewModel: AddDataViewModel(
            healthDataRepo: MockHealthDataRepository(),
            healthDataStore: HealthDataStore(),
            logService: nil
        ),
        config: AddDataViewConfig(
            metric: .steps,
            onCompletion: {}
        )
    )
}
