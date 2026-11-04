//
//  PairingSucessfulView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct PairingSucessfulView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Background {
            VStack {
                Spacer()

                VStack(spacing: Spacing.xs) {
                    Text("You've found your")
                        .font(.luckyHandwritten)
                        .kerning(2)
                        .foregroundStyle(Color.charcoal)

                    Text("Lucky Star")
                        .font(.luckyHeroTitle)
                        .foregroundStyle(Color.luckyBlue)
                }

                Spacer()

                Image("PairingSuccess")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240)
                    .accessibilityHidden(true)

                Spacer()
                Spacer()

                Text("You are now paired!")
                    .font(.luckyHandwritten)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.center)

                Button("Go to dashboard") {
                    appState.completeOnboarding()
                }
                .buttonStyle(.luckyPrimary)
                .padding(.top, Spacing.xl)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 130)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PairingSucessfulView()
        .environment(AppState())
}
