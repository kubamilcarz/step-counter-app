//
//  ChartContainer.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import SwiftUI

struct ChartContainerConfiguration {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
}

struct ChartContainer<Content: View>: View {
    
    let config: ChartContainerConfiguration
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            if config.isNav {
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
        NavigationLink(value: config.context) {
            HStack {
                titleView
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
    
    private var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? .pink : .indigo)
            
            Text(config.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ChartContainer(
        config: .init(title: "Steps", symbol: "figure", subtitle: "Last 28 Days", context: .steps, isNav: true)
    ) {
        Text("Chart")
    }
}
