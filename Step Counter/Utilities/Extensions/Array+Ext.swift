//
//  Array+Ext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import Foundation

extension Array where Element == Double {
    /// Computes the average of all elements. Returns 0 for empty arrays.
    var average: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0, +)
        return total/Double(self.count)
    }
}
