//
//  AddDataViewConfig.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 01/11/2025.
//

import Foundation

struct AddDataViewConfig {
    let metric: HealthMetricContext
    let onCompletion: () -> Void

    init(metric: HealthMetricContext, onCompletion: @escaping () -> Void) {
        self.metric = metric
        self.onCompletion = onCompletion
    }
}
