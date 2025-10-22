//
//  ChartContainer.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 22/10/2025.
//

import SwiftUI

struct ChartContainer<Content: View>: View {
    
    var title: String
    var symbol: String
    var subtitle: String
    var context: HealthMetricContext
    var isNav: Bool
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            if isNav {
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
        NavigationLink(value: context) {
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
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context == .steps ? .pink : .indigo)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ChartContainer(title: "Steps", symbol: "figure", subtitle: "Last 28 Days", context: .steps, isNav: true) {
        Text("Chart")
    }
}
