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
}

struct Couple: Codable, Identifiable {
    let id: UUID
    let relationshipStartDate: String
    let partner: Partner?
}
