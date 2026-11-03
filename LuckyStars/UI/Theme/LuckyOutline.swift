//
//  LuckyOutline.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 25/10/2026.
//
//  A fill, charcoal outline and small hard shadow for any shape (search bar,
//  filter button, category tiles, tab bar).
//

import SwiftUI

struct LuckyOutlineModifier<S: InsettableShape>: ViewModifier {
    let shape: S
    var fill: Color = .cardFill
    var stroke: Color = .charcoal
    var lineWidth: CGFloat = Outline.thick
    /// nil scales the shadow with the shape's size; 0 means no shadow.
    var shadowOffset: CGFloat? = nil

    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geo in
                let offset = shadowOffset ?? Outline.shadow(for: geo.size)
                ZStack {
                    if offset > 0 {
                        shape.fill(Color.charcoal).offset(x: offset, y: offset)
                    }
                    shape.fill(fill)
                    shape.strokeBorder(stroke, lineWidth: lineWidth)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

extension View {
    func luckyOutline<S: InsettableShape>(
        _ shape: S,
        fill: Color = .cardFill,
        stroke: Color = .charcoal,
        lineWidth: CGFloat = Outline.thick,
        shadowOffset: CGFloat? = nil
    ) -> some View {
        modifier(LuckyOutlineModifier(shape: shape, fill: fill, stroke: stroke, lineWidth: lineWidth, shadowOffset: shadowOffset))
    }
}
