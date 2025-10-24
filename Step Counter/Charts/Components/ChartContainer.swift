//
//  ChartContainer.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
    
    var isNav: Bool {
        switch self {
        case .stepBar, .weightLine:
            true
        case .stepWeekdayPie, .weightDiffBar:
            false
        }
    }
    
    var context: HealthMetricContext {
        switch self {
        case .stepBar, .stepWeekdayPie:
            .steps
        case .weightDiffBar, .weightLine:
            .weight
        }
    }
    
    var title: String {
        switch self {
        case .stepBar:
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine:
            "Weight"
        case .weightDiffBar:
            "Average Weight Change"
        }
    }
    
    var symbol: String {
        switch self {
        case .stepBar:
            "figure.walk"
        case .stepWeekdayPie:
            "calendar"
        case .weightLine, .weightDiffBar:
            "figure"
        }
    }
    
    var subtitle: String {
        switch self {
        case .stepBar(let average):
            "Avg: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 Days"
        case .weightLine(let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 Days)"
        }
    }
    
    var accessabilityLabel: String {
        switch self {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average.formatted())"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine(let average):
            "Line chart, weight, average weight: \(average.formatted(.number.precision(.fractionLength(1)))) pounds,  goal weight: 155 pounds"
        case .weightDiffBar:
            "Bar chart, average weight difference per weekday"
        }
    }
}

struct ChartContainer<Content: View>: View {
    let chartType: ChartType
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            if chartType.isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
    
    private var navigationLinkView: some View {
        NavigationLink(value: chartType.context) {
            HStack {
                titleView
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityHint("Tap for data in list view")
    }
    
    private var titleView: some View {
        VStack(alignment: .leading) {
            Label(chartType.title, systemImage: chartType.symbol)
                .font(.title3.bold())
                .foregroundStyle(chartType.context.color)
            
            Text(chartType.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(chartType.accessabilityLabel)
        .accessibilityElement(children: .ignore)
    }
}

#Preview {
    ChartContainer(chartType: .stepWeekdayPie) {
        Text("Chart")
    }
}
