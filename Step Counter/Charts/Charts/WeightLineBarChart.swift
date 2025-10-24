//
//  WeightLineChart.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 15/10/2025.
//

import Charts
import SwiftUI

struct WeightLineChart: View {
    
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
        ChartContainer(chartType: .weightLine(average: chartData.map(\.value).average)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                
                // TODO: Implement user goal
                RuleMark(y: .value("Goal", 155))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    .accessibilityHidden(true)
                
                ForEach(chartData) { weight in
                    Plot {
                        AreaMark(
                            x: .value("Day", weight.date, unit: .day),
                            yStart: .value("Value", weight.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .indigo.opacity(0)]))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                    .accessibilityLabel(weight.date.accessibilityDate)
                    .accessibilityValue("\(weight.value.formatted(.number.precision(.fractionLength(1)))) pounds")
                }
            }
            .frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    AxisValueLabel()
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(title: "No Data", systemImage: "chart.line.downtrend.xyaxis", description: "There is no step count data from the Health App.")
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
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
}
