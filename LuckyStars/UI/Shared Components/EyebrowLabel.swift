//
//  EyebrowLabel.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  Small blue caps label with an icon, above a card title ("YOUR NEXT DATE").
//

import SwiftUI

struct EyebrowLabel: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text.uppercased())
        }
        .font(.luckyCaptionStrong)
        .foregroundStyle(Color.luckyBlue)
    }
}

#Preview {
    EyebrowLabel(icon: "calendar", text: "Your next date")
        .padding()
}
