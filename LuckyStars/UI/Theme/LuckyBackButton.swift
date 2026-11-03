//
//  LuckyBackButton.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 27/10/2026.
//
//  Round, outlined back button with the hard offset shadow.
//

import SwiftUI

struct LuckyBackButton: View {
    var action: () -> Void

    var body: some View {
        LuckyCircleButton(systemName: "chevron.left", label: "Back", action: action)
    }
}

/// Round, outlined X for dismissing sheets.
struct LuckyCloseButton: View {
    var action: () -> Void

    var body: some View {
        LuckyCircleButton(systemName: "xmark", label: "Close", action: action)
    }
}

struct LuckyCircleButton: View {
    let systemName: String
    let label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.charcoal)
                .frame(width: 44, height: 44)
                .background {
                    ZStack {
                        Circle().fill(Color.charcoal).offset(x: Outline.shadowMin, y: Outline.shadowMin)
                        Circle().fill(Color.cardFill)
                        Circle().strokeBorder(Color.charcoal, lineWidth: Outline.thick)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct LuckyBackNavigation: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    var title: String?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .top) {
                ZStack {
                    if let title {
                        Text(title)
                            .font(.luckyScreenTitle)
                            .foregroundStyle(Color.charcoal)
                    }

                    HStack {
                        LuckyBackButton { dismiss() }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
    }
}

extension View {
    /// Replaces the system back button (and optional title) with the Lucky Stars header. Hides the navigation bar.
    func luckyBackButton(title: String? = nil) -> some View {
        modifier(LuckyBackNavigation(title: title))
    }
}

#Preview {
    LuckyBackButton {}
        .padding(40)
        .background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
