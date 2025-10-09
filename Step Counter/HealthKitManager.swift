//
//  HealthKitManager.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 09/10/2025.
//

import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitManager {
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
}
