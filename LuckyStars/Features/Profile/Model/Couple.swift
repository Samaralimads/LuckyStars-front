//
//  Couple.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/05/2026.
//

import Foundation

struct Partner: Codable, Identifiable {
    let id: UUID
    let firstName: String
    /// Whether the partner has a profile photo on the server. Optional so older answers still decode.
    let hasProfilePicture: Bool?
}

struct Couple: Codable, Identifiable {
    let id: UUID
    let relationshipStartDate: String
    let partner: Partner?
}
