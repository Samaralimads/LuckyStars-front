//
//  APIDate.swift
//  LuckyStars
//
//  The date formats the API speaks, in one place.
//
//  - Day ("yyyy-MM-dd"): birth date, anniversary, important dates. A calendar day
//    has no time zone, so it is read and written in the user's own time zone.
//    The day they pick is the day that is saved and shown.
//  - Date and time ("yyyy-MM-dd HH:mm"): planned activities. A real moment in
//    time, sent as UTC.
//
//  Formatters use a fixed locale and the Gregorian calendar so the output doesn't
//  change with the user's region settings (12-hour clock, Buddhist calendar, ...).
//

import Foundation

nonisolated enum APIDate {
    nonisolated(unsafe) private static let dayFormatter = makeFormatter("yyyy-MM-dd", timeZone: nil)
    nonisolated(unsafe) private static let dateTimeFormatter = makeFormatter("yyyy-MM-dd HH:mm", timeZone: TimeZone(identifier: "UTC"))

    private static func makeFormatter(_ format: String, timeZone: TimeZone?) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        if let timeZone { formatter.timeZone = timeZone }
        return formatter
    }

    // MARK: - Day
    static func dayString(from date: Date) -> String {
        dayFormatter.timeZone = .current
        return dayFormatter.string(from: date)
    }

    static func day(from string: String) -> Date? {
        dayFormatter.timeZone = .current
        return dayFormatter.date(from: string)
    }

    // MARK: - Date and time
    static func dateTimeString(from date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }

    static func dateTime(from string: String) -> Date? {
        dateTimeFormatter.date(from: string)
    }
}
