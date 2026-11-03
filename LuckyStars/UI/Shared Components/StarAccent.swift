//
//  StarAccent.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  A small pink star tucked behind the corner of a card.
//

import SwiftUI

struct StarAccent: View {
    var size: CGFloat = 52

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundStyle(Color.starPink)
            .rotationEffect(.degrees(12))
            .accessibilityHidden(true)
    }
}

#Preview {
    StarAccent().padding()
}
