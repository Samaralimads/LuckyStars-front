//
//  Typography.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/10/2026.
//
//  Lucky Stars type scale: Gaegu for titles and buttons, Nunito for body text.
//  Every style scales with Dynamic Type through `relativeTo`.
//

import SwiftUI

extension Font {

    // MARK: - Gaegu (titles, buttons, labels)

    /// Welcome screen title.
    static let luckyHeroTitle = Font.custom("Gaegu-Bold", size: 48, relativeTo: .largeTitle)

    /// Title of a card or form ("Welcome back").
    static let luckyTitle = Font.custom("Gaegu-Bold", size: 34, relativeTo: .title)

    /// Navigation bar title ("Settings").
    static let luckyScreenTitle = Font.custom("Gaegu-Bold", size: 32, relativeTo: .title2)

    /// Title inside a card ("Together for", an activity title).
    static let luckyHeadline = Font.custom("Gaegu-Bold", size: 26, relativeTo: .title3)

    /// Row label ("Pick a date").
    static let luckyLabel = Font.custom("Gaegu-Bold", size: 20, relativeTo: .headline)

    /// Label of a button.
    static let luckyButton = Font.custom("Gaegu-Bold", size: 22, relativeTo: .headline)

    /// Regular Gaegu, for lighter labels ("you've found your").
    static let luckyHandwritten = Font.custom("Gaegu-Regular", size: 24, relativeTo: .title3)

    // MARK: - Nunito (body)

    static let luckyBody = Font.custom("Nunito-Regular", size: 16, relativeTo: .body)

    static let luckyBodyStrong = Font.custom("Nunito-Bold", size: 16, relativeTo: .body)

    static let luckyBodySemibold = Font.custom("Nunito-SemiBold", size: 16, relativeTo: .body)

    static let luckySubheadline = Font.custom("Nunito-Regular", size: 14, relativeTo: .subheadline)

    static let luckySubheadlineStrong = Font.custom("Nunito-Bold", size: 14, relativeTo: .subheadline)

    /// Small uppercase labels and tags.
    static let luckyCaption = Font.custom("Nunito-SemiBold", size: 12, relativeTo: .caption)

    static let luckyCaptionStrong = Font.custom("Nunito-Bold", size: 12, relativeTo: .caption)
}
