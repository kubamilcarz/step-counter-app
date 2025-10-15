//
//  WeightDiffBarChart.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 15/10/2025.
//

import Charts
import SwiftUI

struct WeightDiffBarChart: View {
    
    var chartData: [WeekdayChartData]
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var minValue: Double {
        chartData.map(\.value).min() ?? 0
    }
    
    var selectedWeekday: WeekdayChartData? {
        guard let rawSelectedDate else { return nil }
        
        return chartData.first(where: {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        })
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Label("Average Weight Change", systemImage: "figure")
                    .font(.title3.bold())
                    .foregroundStyle(.indigo)
                
                Text("Per Weekday: (Last 28 Days)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ChartEmptyView(title: "No Data", systemImage: "chart.bar", description: "There is no step count data from the Health App.")
            } else {
                Chart {
                    if let selectedWeekday {
                        RuleMark(x: .value("Selected Day", selectedWeekday.date, unit: .day))
                            .foregroundStyle(.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView
                            }
                    }
                    
                    ForEach(chartData) { weightDiff in
                        BarMark(
                            x: .value("Day", weightDiff.date, unit: .day),
                            y: .value("Value", weightDiff.value)
                        )
                        .foregroundStyle(weightDiff.value >= 0 ? .indigo : .mint)
                        .opacity(rawSelectedDate == nil || weightDiff.date == selectedWeekday?.date ? 1 : 0.3)
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
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
    
    private var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedWeekday?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.title3.bold())
                .contentTransition(.identity)

            Text(selectedWeekday?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle(selectedWeekday?.value ?? 0 >= 0 ? .indigo : .mint)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
}
