//
//  FavoriteStar.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  The favorite star: yellow with a thin charcoal stroke. When it isn't a favorite it is
//  just the stroke, and filling it keeps the same outline.
//

import SwiftUI

struct FavoriteStar: View {
    var isFilled = true
    var size: CGFloat = 22

    var body: some View {
        StarShape()
            .fill(isFilled ? Color.starYellow : Color.clear)
            .overlay {
                StarShape()
                    .stroke(Color.charcoal, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            }
            .frame(width: size, height: size)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFilled)
            .accessibilityLabel(isFilled ? "Favorite" : "Not a favorite")
    }
}

/// A five-pointed star with softly rounded tips, filling its rect.
private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Inset a little so the stroke isn't clipped at the edges.
        let outer = min(rect.width, rect.height) / 2 - 1
        let inner = outer * 0.48
        let center = CGPoint(x: rect.midX, y: rect.midY + outer * 0.06)

        var path = Path()
        for i in 0..<10 {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = (Double(i) * .pi / 5) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            i == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    HStack(spacing: 20) {
        FavoriteStar(isFilled: true)
        FavoriteStar(isFilled: false)
        FavoriteStar(isFilled: true, size: 44)
    }
    .padding()
    .background(Color.cardFill)
}
