//
//  StepPieChart.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Charts
import SwiftUI

struct StepPieChart: View {
    
    var chartData: [DateValueChartData]
    
    @State private var rawSelectedChartValue: Double? = 0
    @State private var lastSelectedValue: Double = 0
    @State private var selectedDay: Date?
    
    var selectedWeekday: DateValueChartData? {
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return lastSelectedValue <= total
        }
    }
    
    var body: some View {
        ChartContainer(chartType: .stepWeekdayPie) {
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.618),
                        outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(6)
                    .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1 : 0.3)
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
            .animation(.snappy, value: lastSelectedValue)
            .onChange(of: rawSelectedChartValue) { oldValue, newValue in
                guard let newValue else {
                    lastSelectedValue = oldValue ?? 0
                    return
                }
                
                lastSelectedValue = newValue
            }
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .contentTransition(.identity)
                                
                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(title: "No Data", systemImage: "chart.pie", description: "There is no step count data from the Health App.")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: MockData.steps))
}
