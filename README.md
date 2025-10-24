# Step Tracker
Step Tracker integrates Apple Health to show your latest step and weight data in animated, interactive Swift Charts. You can also see your average steps and weight gain/loss for each weekday for the past 28 days.

Step Tracker also allows you to upload new step or weight data to the Apple Health app.

# Technologies Used
* SwiftUI
* HealthKit
* Swift Charts
* Swift Algorithms
* DocC
* Git & GitHub

# Animated Swift Charts
[Watch: Animated Charts Demo](https://github.com/kubamilcarz/step-counter-app/blob/59fa57fb9dd91bf3b838f5fdb29e060cf07702c4/readme-assets/readme-animated-charts.mov)

# I'm Most Proud Of...
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
<br>
</br>

![readme-weight-diff](https://github.com/kubamilcarz/step-counter-app/blob/59fa57fb9dd91bf3b838f5fdb29e060cf07702c4/readme-assets/readme-weight-diff.png)


# Completeness
Although it's a simple portfolio project, I've implemented the following:
* Error handling & alerts
* Empty states
* Permission Priming
* Text input validation
* Basic unit tests
* Basic accessibility
* Privacy Manifest
* Code documentation (DocC)
* Project organization