//
//  Date+Ext.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 14/10/2025.
//

import Foundation

/// Extensions for `Date` providing convenient access to weekday information and formatted strings.
///
/// These extensions simplify common date operations throughout the app, particularly
/// for weekday-based grouping, chart labels, and accessibility features.
extension Date {
    
    /// Returns the weekday as an integer according to the current calendar.
    ///
    /// This computed property provides quick access to the weekday component of a date,
    /// which is essential for grouping health metrics by day of the week.
    ///
    /// ## Weekday Values
    /// The returned integer follows the Gregorian calendar convention:
    ///
    /// | Weekday | Integer Value |
    /// |---------|---------------|
    /// | Sunday | 1 |
    /// | Monday | 2 |
    /// | Tuesday | 3 |
    /// | Wednesday | 4 |
    /// | Thursday | 5 |
    /// | Friday | 6 |
    /// | Saturday | 7 |
    ///
    /// ## Use Cases
    /// - **Sorting**: Group health data by weekday for trend analysis
    /// - **Chunking**: Separate data points by day of the week
    /// - **Comparison**: Check if two dates fall on the same weekday
    ///
    /// ### Examples
    /// ```swift
    /// // October 24, 2025 is a Friday
    /// let date = Date() // Oct 24, 2025
    /// print(date.weekdayInt) // Prints: 6
    ///
    /// // Grouping by weekday
    /// let sorted = healthMetrics.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
    /// ```
    ///
    /// - Returns: An integer from 1 (Sunday) to 7 (Saturday).
    ///
    /// - Note: Uses the user's current calendar settings. In some locales, Monday may be
    ///   considered the first day of the week, but the numbering remains the same.
    /// - SeeAlso: `ChartHelper.averageWeekdayCount(for:)` for usage in weekday averaging.
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// Returns the full weekday name in the user's current locale.
    ///
    /// This computed property formats the date to display only the weekday name,
    /// useful for chart labels, headers, and user-facing date displays.
    ///
    /// ## Localization
    /// The weekday name is automatically localized based on the user's language settings:
    ///
    /// | Locale | Example Output |
    /// |--------|----------------|
    /// | English (US) | "Friday" |
    /// | Spanish | "viernes" |
    /// | French | "vendredi" |
    /// | German | "Freitag" |
    ///
    /// ## Use Cases
    /// - Chart axis labels showing weekday names
    /// - Pie chart section labels
    /// - List headers grouped by weekday
    /// - Summary reports
    ///
    /// ### Examples
    /// ```swift
    /// // October 24, 2025 is a Friday
    /// let date = Date()
    /// print(date.weekdayTitle) // "Friday" (in English)
    ///
    /// // In SwiftUI chart
    /// Text(dataPoint.date.weekdayTitle)
    ///     .font(.caption)
    /// ```
    ///
    /// - Returns: The full weekday name as a `String` (e.g., "Monday", "Tuesday").
    ///
    /// - Note: Returns the full name (`.wide` format), not abbreviated.
    /// - Important: Output varies by locale. Don't use for programmatic comparisons.
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    /// Returns an accessibility-friendly date string showing the month and day.
    ///
    /// This computed property formats the date for VoiceOver and accessibility features,
    /// providing a clear, spoken-friendly representation of the date without unnecessary
    /// information like the year or time.
    ///
    /// ## Format
    /// - **Full month name** + **day number**
    /// - Example: "October 24"
    /// - Automatically localized to the user's language
    ///
    /// ## Accessibility Benefits
    /// - **VoiceOver**: Reads naturally (e.g., "October twenty-fourth")
    /// - **Concise**: Omits year for recent dates, reducing verbosity
    /// - **Clear**: Full month names are less ambiguous than numbers
    ///
    /// ## Use Cases
    /// - Chart data point descriptions for VoiceOver users
    /// - Accessibility labels on interactive elements
    /// - Screen reader announcements
    /// - Alternative text for date-based UI elements
    ///
    /// ### Examples
    /// ```swift
    /// let date = Date() // October 24, 2025
    /// print(date.accessibilityDate) // "October 24"
    ///
    /// // In SwiftUI for accessibility
    /// ChartMark(...)
    ///     .accessibilityLabel(dataPoint.date.accessibilityDate)
    ///     .accessibilityValue("\(dataPoint.value) steps")
    /// ```
    ///
    /// - Returns: A formatted date string as "Month Day" (e.g., "October 24").
    ///
    /// - Note: Year is intentionally omitted for brevity in recent date contexts.
    /// - Important: This format is optimized for screen readers, not general display.
    /// - SeeAlso: Apple's Human Interface Guidelines for Accessibility
    var accessibilityDate: String {
        self.formatted(.dateTime.month(.wide).day())
    }
}
