//
//  Category.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 17/02/2026.
//

import Foundation

struct Category: Codable, Identifiable {
    let id: UUID
    let name: String
    
    var imageName: String {
        switch name {
        case "Food & Drinks": return "Food&Drinks"
        case "Nature":        return "Nature"
        case "Creative":      return "Creative"
        case "Culture":       return "Culture"
        case "Active":        return "Active"
        default:              return "Sparkles"
        }
    }
}
