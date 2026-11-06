//
//  ProfileService.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 20/05/2026.
//

import Foundation
import UIKit

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

    // MARK: - Photos
    /// Sends the user's photo (shrunk first: a profile circle never needs the full-size picture).
    static func uploadMyPicture(_ image: UIImage) async throws {
        guard let data = image.resizedToFit(maxDimension: 800).jpegData(compressionQuality: 0.8) else { return }
        try await APIClient.shared.uploadData("/users/me/picture", data: data, contentType: "image/jpeg")
    }

    static func fetchMyPicture() async throws -> UIImage? {
        guard let data = try await APIClient.shared.downloadData("/users/me/picture") else { return nil }
        return UIImage(data: data)
    }

    static func fetchPartnerPicture() async throws -> UIImage? {
        guard let data = try await APIClient.shared.downloadData("/couples/me/partner/picture") else { return nil }
        return UIImage(data: data)
    }
}

extension UIImage {
    /// The same picture, no bigger than `maxDimension` on its longest side.
    func resizedToFit(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
