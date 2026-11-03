//
//  OrDivider.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/10/2026.
//
//  A thin line, "or", a thin line.
//

import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack(spacing: Spacing.m) {
            Rectangle()
                .fill(Color.rowDivider)
                .frame(height: 1)

            Text("or")
                .font(.luckyButton)
                .foregroundStyle(Color.charcoal)

            Rectangle()
                .fill(Color.rowDivider)
                .frame(height: 1)
        }
    }
}

#Preview {
    OrDivider()
        .padding()
        .background(Color.cardFill)
}
