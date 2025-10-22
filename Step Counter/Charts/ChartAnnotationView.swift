//
//  ChartAnnotationView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import SwiftUI

struct ChartAnnotationView: View {
    
    var data: DateValueChartData
    var context: HealthMetricContext
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(data.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)

            Text(data.value, format: .number.precision(.fractionLength(context == .steps ? 0 : 1)))
                .fontWeight(.heavy)
                .foregroundStyle(context == .steps ? .pink : .indigo)
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
    ChartAnnotationView(
        data: .init(date: .now, value: 1_000),
        context: .steps
    )
}
