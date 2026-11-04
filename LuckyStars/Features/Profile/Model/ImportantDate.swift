//
//  ImportantDate.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 16/02/2026.
//

import Foundation

struct ImportantDate: Codable, Identifiable  {
    let id: UUID
    var label: String
    var date: Date
    /// Shown as "Every year"; the next occurrence is displayed instead of the stored date.
    var repeatsYearly: Bool = false
    /// Days before the date to remind; nil means no reminder, 0 means on the day.
    var reminderDaysBefore: Int? = nil
}

