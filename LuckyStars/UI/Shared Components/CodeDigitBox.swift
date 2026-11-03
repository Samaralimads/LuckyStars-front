//
//  CodeDigitBox.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct CodeDigitBox: View {
    let digit: String
    let isActive: Bool
    var width: CGFloat = 44

    var body: some View {
        Text(digit)
            .font(.luckyHeadline)
            .foregroundStyle(Color.charcoal)
            .frame(width: width, height: 56)
            .background(
                RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                    .fill(Color.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                    .strokeBorder(
                        isActive ? Color.luckyBlue : Color.fieldBorder,
                        lineWidth: Outline.field
                    )
            )
    }
}

#Preview {
    HStack {
        CodeDigitBox(digit: "3", isActive: true)
        CodeDigitBox(digit: "", isActive: false)
    }
    .padding()
    .background(Color.cardFill)
}
