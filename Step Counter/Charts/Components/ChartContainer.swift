//
//  ChartContainer.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import SwiftUI

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
        .background(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .stroke(.gray.opacity(0.5), lineWidth: 0.5)
            .fill(Color(.secondarySystemBackground).gradient.opacity(0.5))
        )
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
