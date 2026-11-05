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
        let body = CreateCoupleRequest(relationshipStartDate: APIDate.dayString(from: anniversaryDate))
        return try await APIClient.shared.request("/couples/create", method: "POST", body: body)
    }

    // MARK: - Update anniversary (either partner)
    struct UpdateCoupleRequest: Encodable {
        let relationshipStartDate: String
    }

    static func updateRelationshipStartDate(_ date: Date) async throws -> Couple {
        let body = UpdateCoupleRequest(relationshipStartDate: APIDate.dayString(from: date))
        return try await APIClient.shared.request("/couples/me", method: "PUT", body: body)
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
}
