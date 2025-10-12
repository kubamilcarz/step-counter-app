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
    
    func fetchStepCount() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -20, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: .init(day: 1)
        )
        
        let stepsCounts = try! await stepsQuery.result(for: store)
    }
    
    func fetchWeightsCount() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -20, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: .init(day: 1)
        )
        
        let weightsCount = try! await weightsQuery.result(for: store)
    }
    
    func addSimulatorData() async {
        var mockSamples: [HKQuantitySample] = []
        
        for i in 0..<20 {
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 1_000...20_000))
            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: 160 + Double(i/3)...165 + Double(i/5)))
            
            let startDate = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!

            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
            
            mockSamples.append(stepSample)
            mockSamples.append(weightSample)
        }
        
        try! await store.save(mockSamples)
        print("Dummy data added")
    }
}
