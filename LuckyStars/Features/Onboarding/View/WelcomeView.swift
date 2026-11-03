//
//  WelcomeView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct WelcomeView: View {
    @State private var illustrationOpacity = 0.0

    var body: some View {

        Background {

            VStack {

                VStack(spacing: Spacing.xs) {
                    Text("Welcome to")
                        .font(.luckyHandwritten)
                        .kerning(2)
                        .foregroundStyle(Color.charcoal)

                    Text("Lucky Stars")
                        .font(.luckyHeroTitle)
                        .foregroundStyle(Color.luckyBlue)
                }
                .padding(.top, 60)

                Spacer()

                Image("WelcomeStars")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .opacity(illustrationOpacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            illustrationOpacity = 1
                        }
                    }
                    .accessibilityHidden(true)

                Spacer()

                VStack(spacing: Spacing.m) {

                    NavigationLink(
                        destination:
                            SignUpView().navigationBarBackButtonHidden(true))
                    {
                        Text("Create Account")
                    }
                    .buttonStyle(.luckyPrimary)

                    NavigationLink(destination:
                                    SignInView().navigationBarBackButtonHidden(true))
                    {
                        Text("Log in")
                    }
                    .buttonStyle(.luckySecondary)
                }

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 90)
        }
    }
}

#Preview {
    WelcomeView()
}
