# Step Tracker

Step Tracker integrates Apple Health to show your latest step and weight data in animated, interactive Swift Charts. You can also see your average steps and weight gain/loss for each weekday for the past 28 days.

Step Tracker also allows you to upload new step or weight data to the Apple Health app. The 1.2.0 release layered on the Apple “Liquid Glass” dashboard treatment, introduced a foundation-model powered AI coach for streaming insights, and tightened Swift 6.2 backwards-compatibility by keeping HealthKit updates main-actor safe.


## Technologies Used

* SwiftUI
* MVVM with `@Observable` view models
* HealthKit
* Swift Charts
* Swift Algorithms
* Foundation Models (Coach insights)
* Swift Concurrency (Swift 6.2 main-actor isolation)
* Custom dependency container & App Delegate wiring
* String Catalog localization (English & Polish)
* DocC
* Git & GitHub

## Architecture & Dependency Injection

* Views and view models follow MVVM: every screen pairs a SwiftUI view with an `@Observable` view model (for example `Step Counter/Screens/Dashboard/DashboardView.swift` + `DashboardViewModel.swift`). The view models encapsulate fetch logic, permission prompts, and transient UI state so the views stay declarative.
* Shared services flow through a lightweight DI layer. `AppDelegate.swift` resolves the active `BuildConfiguration` (`.mock`, `.dev`, `.prod`) using compile-time flags and assembles a `Dependencies` bundle.
* `Dependencies.swift` hydrates singletons (`HealthKitManager`, `HealthKitData`) and registers them with the `DependencyContainer`. The `StepCounterApp` then injects them into the SwiftUI hierarchy with `.environment`, so previews and child views can resolve the same instances without tight coupling.

## Build Flavors & Configuration

* Three Xcode schemes (`Dev.xcscheme`, `Mock.xcscheme`, `Prod.xcscheme`) map to dedicated build configurations. Each scheme flips a Swift compile flag (`-DDEV`, `-DMOCK`) that informs the `BuildConfiguration` enum inside `AppDelegate.swift`.
* The DI layer uses those build flavors to toggle behavior. The current implementation showcases the wiring.

## Localization & Polish QA Loop

* All user-facing strings live in `Step Counter/Utilities/Localizable.xcstrings`, managed through Xcode string catalogs. English is the source language and Polish (`pl`) translations cover every chart label, and alert (for example `"%lld steps" → "%lld kroków"`).

## Animated Swift Charts

[Watch: Animated Charts Demo](https://github.com/kubamilcarz/step-counter-app/blob/59fa57fb9dd91bf3b838f5fdb29e060cf07702c4/readme-assets/readme-animated-charts.mov)

## What I'm Most Proud Of

The average weight difference per day of the week bar chart. Determining which day of the week were problem days for someone trying to lose weight struck me as a great insight to surface from the weight data.

I pulled the last 29 days of weights and ran a calculation to track the differences between each weekday. I then averaged each weekday's gain/loss and displayed them in a bar chart and conditionally colored the positive and negative weight change values.

Here's the code (Charts/Utilities/ChartHelper.swift):

```swift
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData] {
        guard weights.count > 1 else { return [] }

        var diffValues: [(date: Date, value: Double)] = []
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekdayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeightDiff = total/Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: avgWeightDiff))
        }
        
        return weekdayChartData
    }
```
![readme-weight-diff](https://github.com/kubamilcarz/step-counter-app/blob/59fa57fb9dd91bf3b838f5fdb29e060cf07702c4/readme-assets/readme-weight-diff.png)


## Completeness

Although it's a simple portfolio project, I've implemented the following:

* Error handling & alerts
* Empty states
* Permission Priming
* Text input validation
* Basic unit tests
* Basic accessibility
* Polish localization coverage via string catalogs
* Privacy Manifest
* Code documentation (DocC)
* Project organization
* Apple “Liquid Glass” dashboard styling
* AI coach powered by foundation models
* Swift 6.2 backwards-compatibility guardrails