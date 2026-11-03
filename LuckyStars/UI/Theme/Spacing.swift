//
//  Spacing.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/10/2026.
//
//  Spacing, radius and outline tokens shared by every screen.
//

import SwiftUI

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum Radius {
    /// Cards and sheets.
    static let card: CGFloat = 30
    /// Small tiles (code boxes, stat tiles, category tiles).
    static let tile: CGFloat = 16
}

enum Outline {
    /// Charcoal outline of cards, buttons and the tab bar.
    static let thick: CGFloat = 2
    /// Grey outline of fields and code boxes.
    static let field: CGFloat = 1.5
    /// Largest offset of the hard charcoal shadow (wide, tall cards). Also the space reserved for it.
    static let shadowOffset: CGFloat = 4
    /// Offset for small or short elements (pills, buttons, chips, round buttons).
    static let shadowMin: CGFloat = 2

    /// The shadow grows with the element, as in the Figma: roughly its shorter side / 40, between the min and max.
    static func shadow(for size: CGSize) -> CGFloat {
        min(max(min(size.width, size.height) / 40, shadowMin), shadowOffset)
    }
}
