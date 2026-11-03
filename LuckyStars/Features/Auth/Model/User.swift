//
//  User.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/05/2026.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let firstName: String
    let birthDate: String
    let email: String
    let profilePicture: String?
}
