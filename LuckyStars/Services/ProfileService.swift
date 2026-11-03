//
//  ProfileService.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 20/05/2026.
//

import Foundation

struct ProfileService {

    // MARK: - Request Models
    struct UpdateUserRequest: Encodable {
        let firstName: String?
        let email: String?
        let profilePicture: String?
    }

    struct ImportantDateRequest: Encodable {
        let label: String
        let date: String
        let repeatYearly: Bool
        let reminderEnabled: Bool
        let reminderDaysBefore: Int?
    }

    // MARK: - Response Models
    struct ImportantDateResponse: Decodable, Identifiable {
        let id: UUID
        let label: String
        let date: String
        // Optional so an older backend that doesn't send them still decodes.
        let repeatYearly: Bool?
        let reminderEnabled: Bool?
        let reminderDaysBefore: Int?
    }

    // MARK: - Fetch current user
    static func fetchMe() async throws -> User {
        return try await APIClient.shared.request("/users/me")
    }

    // MARK: - Update current user
    static func updateMe(firstName: String? = nil, email: String? = nil, profilePicture: String? = nil) async throws -> User {
        let body = UpdateUserRequest(firstName: firstName, email: email, profilePicture: profilePicture)
        return try await APIClient.shared.request("/users/me", method: "PUT", body: body)
    }

    // MARK: - Fetch couple
    static func fetchCouple() async throws -> Couple {
        return try await APIClient.shared.request("/couples/me")
    }

    // MARK: - Fetch important dates
    static func fetchImportantDates() async throws -> [ImportantDateResponse] {
        return try await APIClient.shared.request("/important-dates")
    }

    // MARK: - Create important date
    static func createImportantDate(label: String, date: String, repeatYearly: Bool, reminderDaysBefore: Int?) async throws -> ImportantDateResponse {
        let body = ImportantDateRequest(label: label, date: date, repeatYearly: repeatYearly, reminderEnabled: reminderDaysBefore != nil, reminderDaysBefore: reminderDaysBefore)
        return try await APIClient.shared.request("/important-dates", method: "POST", body: body)
    }

    // MARK: - Update important date
    static func updateImportantDate(id: UUID, label: String, date: String, repeatYearly: Bool, reminderDaysBefore: Int?) async throws -> ImportantDateResponse {
        let body = ImportantDateRequest(label: label, date: date, repeatYearly: repeatYearly, reminderEnabled: reminderDaysBefore != nil, reminderDaysBefore: reminderDaysBefore)
        return try await APIClient.shared.request("/important-dates/\(id.uuidString)", method: "PUT", body: body)
    }

    // MARK: - Delete important date
    static func deleteImportantDate(id: UUID) async throws {
        try await APIClient.shared.requestEmpty("/important-dates/\(id.uuidString)", method: "DELETE")
    }
}
