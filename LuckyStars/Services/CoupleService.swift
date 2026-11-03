//
//  CoupleService.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 20/05/2026.
//

import Foundation

struct CoupleService {

    // MARK: - Request Models
    struct CreateCoupleRequest: Encodable {
        let relationshipStartDate: String
    }

    struct JoinCoupleRequest: Encodable {
        let invitationCode: String
    }

    // MARK: - Response Models
    struct InvitationResponse: Decodable {
        let code: String
    }

    // MARK: - Create couple (User 1)
    static func createCouple(anniversaryDate: Date) async throws -> Couple {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let body = CreateCoupleRequest(relationshipStartDate: formatter.string(from: anniversaryDate))
        return try await APIClient.shared.request("/couples/create", method: "POST", body: body)
    }

    // MARK: - Join couple (User 2)
    static func joinCouple(invitationCode: String) async throws -> Couple {
        let body = JoinCoupleRequest(invitationCode: invitationCode)
        return try await APIClient.shared.request("/couples/join", method: "POST", body: body)
    }

    // MARK: - Get my invitation code
    static func getMyInvitationCode() async throws -> InvitationResponse {
        return try await APIClient.shared.request("/couples/me/invitation")
    }

    // MARK: - Get my couple
    static func getMyCouple() async throws -> Couple {
        return try await APIClient.shared.request("/couples/me")
    }
}
