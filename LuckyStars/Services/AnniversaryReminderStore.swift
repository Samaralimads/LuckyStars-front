//
//  AnniversaryReminderStore.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//

import Foundation

// Persists the reminder for the anniversary locally (days before; nil = no reminder).
// Not synced to the backend yet: the anniversary lives on the couple, which has no
// per-person reminder field, so this stays on this device.
struct AnniversaryReminderStore {
    private static let key = "anniversaryReminderDaysBefore"

    static func save(_ daysBefore: Int?) {
        if let daysBefore {
            UserDefaults.standard.set(daysBefore, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func load() -> Int? {
        UserDefaults.standard.object(forKey: key) as? Int
    }
}
