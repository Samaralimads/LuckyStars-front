//
//  PlannedActivityService.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 01/06/2026.
//

import Foundation

struct PlannedActivityService {

    // MARK: - Request Models
    struct ProposeRequest: Encodable {
        let activityId: UUID
        let proposedDate: String
        let reminderEnabled: Bool
        let reminderDaysBefore: Int?
    }

    struct DeclineRequest: Encodable {
        let note: String?
    }

    struct RescheduleRequest: Encodable {
        let proposedDate: String
        let note: String?
        let reminderEnabled: Bool
        let reminderDaysBefore: Int?
    }

    // MARK: - Propose
    static func propose(activityId: UUID, date: Date) async throws -> PlannedActivity {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let body = ProposeRequest(
            activityId: activityId,
            proposedDate: formatter.string(from: date),
            reminderEnabled: false,
            reminderDaysBefore: nil
        )
        return try await APIClient.shared.request("/planned-activities", method: "POST", body: body)
    }

    // MARK: - Get couple activities
    static func getCoupleActivities() async throws -> [PlannedActivity] {
        return try await APIClient.shared.request("/planned-activities/couple")
    }

    // MARK: - Accept
    static func accept(id: UUID) async throws -> PlannedActivity {
        return try await APIClient.shared.request("/planned-activities/\(id.uuidString)/accept", method: "PUT")
    }

    // MARK: - Decline
    static func decline(id: UUID, note: String? = nil) async throws -> PlannedActivity {
        let body = DeclineRequest(note: note)
        return try await APIClient.shared.request("/planned-activities/\(id.uuidString)/decline", method: "PUT", body: body)
    }

    // MARK: - Reschedule
    static func reschedule(id: UUID, newDate: Date, note: String? = nil) async throws -> PlannedActivity {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let body = RescheduleRequest(
            proposedDate: formatter.string(from: newDate),
            note: note,
            reminderEnabled: false,
            reminderDaysBefore: nil
        )
        return try await APIClient.shared.request("/planned-activities/\(id.uuidString)/reschedule", method: "PUT", body: body)
    }
}
