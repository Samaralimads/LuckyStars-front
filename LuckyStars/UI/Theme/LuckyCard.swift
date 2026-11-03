//
//  LuckyCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 27/10/2026.
//
//  The Lucky Stars card: cream-white fill, thick charcoal outline and a hard
//  offset shadow.
//

import SwiftUI

struct LuckyCardModifier: ViewModifier {
    var radius: CGFloat = Radius.card
    /// nil scales the shadow with the card's size.
    var shadowOffset: CGFloat? = nil

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geo in
                    let offset = shadowOffset ?? Outline.shadow(for: geo.size)
                    ZStack {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Color.charcoal)
                            .offset(x: offset, y: offset)
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Color.cardFill)
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(Color.charcoal, lineWidth: Outline.thick)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
    }
}

extension View {
    /// Wraps the view in the Lucky Stars card style.
    func luckyCard(radius: CGFloat = Radius.card, shadowOffset: CGFloat? = nil) -> some View {
        modifier(LuckyCardModifier(radius: radius, shadowOffset: shadowOffset))
    }
}

#Preview {
    Text("Hello")
        .font(.luckyTitle)
        .foregroundStyle(Color.luckyBlue)
        .padding(40)
        .luckyCard()
        .padding()
        .background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
