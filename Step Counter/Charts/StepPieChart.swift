//
//  StepPieChart.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Charts
import SwiftUI

struct StepPieChart: View {
    
    var chartData: [WeekdayChartData]
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.618),
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
