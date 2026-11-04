//
//  CalendarEventStore.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 28/09/2026.
//

import Foundation

// Tracks which PlannedActivity already has a matching calendar event, so
// tapping "Add to Calendar" twice doesn't create a duplicate.
struct CalendarEventStore {
    private static let key = "luckystars.calendarEventIdentifiers"

    private static var mapping: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func eventIdentifier(for plannedActivityId: UUID) -> String? {
        mapping[plannedActivityId.uuidString]
    }

    static func setEventIdentifier(_ identifier: String, for plannedActivityId: UUID) {
        var current = mapping
        current[plannedActivityId.uuidString] = identifier
        mapping = current
    }
}
