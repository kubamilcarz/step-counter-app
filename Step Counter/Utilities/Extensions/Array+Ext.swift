//
//  Array+Ext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 24/10/2025.
//

import Foundation

/// Extensions for `Array` providing utility methods for numerical operations.
///
/// These extensions add convenient computed properties and methods to arrays
/// containing specific element types, making common calculations more concise.
extension Array where Element == Double {
    
    /// Computes the arithmetic mean (average) of all elements in the array.
    ///
    /// This computed property calculates the average value of all `Double` elements
    /// in the array using the standard formula:
    ///
    /// ```
    /// Average = (Sum of all elements) / (Number of elements)
    /// ```
    ///
    /// ## Use Cases
    /// - Calculating average step counts across multiple days
    /// - Computing mean weight values
    /// - Determining average metrics for reporting
    ///
    /// ## Behavior
    /// - **Empty Array**: Returns `0` (safe default, no division by zero)
    /// - **Single Element**: Returns that element's value
    /// - **Multiple Elements**: Returns the calculated average
    ///
    /// ### Examples
    /// ```swift
    /// [100.0, 200.0, 300.0].average  // Returns: 200.0
    /// [5.5, 10.5, 15.0].average       // Returns: 10.333...
    /// [42.0].average                  // Returns: 42.0
    /// [].average                      // Returns: 0.0
    /// ```
    ///
    /// - Returns: The average value as a `Double`, or `0` if the array is empty.
    ///
    /// - Complexity: O(n), where n is the number of elements in the array.
    /// - Note: The result is not rounded. Use number formatters for display purposes.
    /// - Important: Empty arrays return `0` instead of throwing an error or returning `nil`.
    ///
    /// ## Implementation Details
    /// Uses `reduce(0, +)` for efficient summation of all elements before division.
    var average: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0, +)
        return total/Double(self.count)
    }
}
