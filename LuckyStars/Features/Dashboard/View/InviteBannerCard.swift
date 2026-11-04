//
//  InviteBannerCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct InviteBannerCard: View {
    let onDismiss: () -> Void

    @State private var code: String?
    @State private var failed = false
    @State private var copied = false

    /// Pass a code to skip the network call (previews). Otherwise it loads your invitation code.
    init(code: String? = nil, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self._code = State(initialValue: code)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: Spacing.m) {
                Text("Share this code with your partner so they can join:")
                    .font(.luckyBody)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.m)

                codePill
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .luckyCard()
            .padding(.trailing, Outline.shadowOffset)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.inkSecondary)
                    .padding(14)
            }
            .buttonStyle(.plain)
            .padding(.trailing, Outline.shadowOffset)
            .accessibilityLabel("Dismiss")
        }
        .task { await loadCode() }
    }

    private func loadCode() async {
        guard code == nil else { return }
        failed = false
        do {
            code = try await CoupleService.getMyInvitationCode().code
        } catch {
            guard !error.isCancellation else { return }
            failed = true
        }
    }

    @ViewBuilder
    private var codePill: some View {
        if let code {
            Button {
                UIPasteboard.general.string = code
                copied = true
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    copied = false
                }
            } label: {
                HStack(spacing: Spacing.s) {
                    Text(code.map(String.init).joined(separator: " "))
                        .font(.luckyHeadline)
                        .foregroundStyle(Color.luckyBlue)

                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.luckySubheadlineStrong)
                        .foregroundStyle(Color.luckyBlue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .overlay(
                    Capsule().strokeBorder(Color.luckyBlue, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Invitation code \(code). Tap to copy.")
        } else if failed {
            VStack(spacing: Spacing.s) {
                Text("Couldn't load your code.")
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.destructiveRed)
                    .multilineTextAlignment(.center)

                Button("Try again") {
                    Task { await loadCode() }
                }
                .font(.luckySubheadlineStrong)
                .foregroundStyle(Color.luckyBlue)
                .underline()
            }
        } else {
            ProgressView()
                .padding(.vertical, Spacing.s)
        }
    }
}

#Preview {
    Background {
        InviteBannerCard(code: "482916", onDismiss: {})
            .padding(20)
    }
}
