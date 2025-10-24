//
//  WeightDiffBarChart.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 15/10/2025.
//

import Charts
import SwiftUI

struct WeightDiffBarChart: View {
    
    var chartData: [DateValueChartData]
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var minValue: Double {
        chartData.map(\.value).min() ?? 0
    }
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Average Weight Change",
            symbol: "figure",
            subtitle: "Per Weekday: (Last 28 Days)",
            context: .weight,
            isNav: false
        )
        
        ChartContainer(config: config) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                ForEach(chartData) { weightDiff in
                    BarMark(
                        x: .value("Day", weightDiff.date, unit: .day),
                        y: .value("Value", weightDiff.value)
                    )
                    .foregroundStyle(weightDiff.value >= 0 ? .indigo : .mint)
                    .opacity(rawSelectedDate == nil || weightDiff.date == selectedData?.date ? 1 : 0.3)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(title: "No Data", systemImage: "chart.bar", description: "There is no step count data from the Health App.")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
}
