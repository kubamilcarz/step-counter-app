//
//  ChartEmptyView.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 15/10/2025.
//

import SwiftUI

struct ChartEmptyView: View {
    
    var title: String
    var systemImage: String
    var description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 8)
            
            Text(title)
                .font(.callout.bold())
            
            Text(description)
                .font(.footnote)
        }
    }
}

#Preview {
    ChartEmptyView(title: "", systemImage: "", description: "")
}
