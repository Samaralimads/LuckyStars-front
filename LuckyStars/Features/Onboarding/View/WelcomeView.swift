//
//  WelcomeView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct WelcomeView: View {
    private struct Slide: Identifiable {
        let id = UUID()
        let image: String
        let title: String
    }

    private let slides = [
        Slide(image: "OnboardingDiscover", title: "Browse activities for every mood"),
        Slide(image: "OnboardingPlan", title: "Plan your dates together"),
        Slide(image: "OnboardingPair", title: "Pair your accounts and unlock new features")
    ]

    @State private var currentSlide = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let autoAdvanceInterval = 4.0
    private static let cardImageHeight: CGFloat = 260
    private static let cardTextHeight: CGFloat = 100

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

                TabView(selection: $currentSlide) {
                    ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                        slideCard(slide)
                            .rotationEffect(.degrees(-1.5))
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.l)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Restarts on every slide change, so a manual swipe resets the countdown.
                .task(id: currentSlide) {
                    guard !reduceMotion else { return }
                    try? await Task.sleep(for: .seconds(autoAdvanceInterval))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentSlide = (currentSlide + 1) % slides.count
                    }
                }

                pageDots
                    .padding(.bottom, Spacing.xl)

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
            .padding(.bottom, 40)
        }
    }

    private func slideCard(_ slide: Slide) -> some View {
        VStack(spacing: 0) {
            Image(slide.image)
                .resizable()
                .scaledToFit()
                .padding(Spacing.l)
                .frame(maxWidth: .infinity)
                .frame(height: Self.cardImageHeight)
                .accessibilityHidden(true)

            Rectangle()
                .fill(Color.charcoal)
                .frame(height: 1)

            Text(slide.title)
                .font(.luckyHeadline)
                .foregroundStyle(Color.charcoal)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.l)
                .frame(maxWidth: .infinity)
                .frame(height: Self.cardTextHeight)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(slides.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentSlide ? Color.charcoal : Color.charcoal.opacity(0.3))
                    .frame(width: index == currentSlide ? 24 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentSlide)
        .accessibilityHidden(true)
    }
}

#Preview {
    WelcomeView()
}
