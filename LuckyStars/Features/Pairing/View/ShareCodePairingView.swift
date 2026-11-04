//
//  ShareCodePairingView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 13/02/2026.
//

import SwiftUI

struct ShareCodePairingView: View {
    /// Onboarding continues to the anniversary step; from Profile there is nothing to continue to.
    var showsNext = true

    @State private var code = ""
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var navigateToAnniversary = false

    var body: some View {
        Background {
            WhiteCard(title: "First one here?", description: "Share this code with your partner to connect your accounts and start planning activities together.") {

                if isLoading {
                    ProgressView()
                        .padding(.vertical, Spacing.xl)
                } else if loadFailed {
                    Text("We couldn't load your code.")
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .padding(.vertical, Spacing.l)

                    Button("Try again") {
                        Task { await loadCode() }
                    }
                    .buttonStyle(.luckyPrimary)
                } else {
                    HStack(spacing: Spacing.s) {
                        ForEach(Array(code.enumerated()), id: \.offset) { _, character in
                            CodeDigitBox(digit: String(character), isActive: false)
                        }
                    }
                    .padding(.vertical, Spacing.l)

                    ShareLink(
                        item: code,
                        subject: Text("Pairing Code"),
                        message: Text("Join me using this pairing code: \(code)")
                    ) {
                        HStack(spacing: Spacing.s) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Code")
                        }
                    }
                    .buttonStyle(.luckyPrimary)

                    if showsNext {
                        Button("Next") {
                            navigateToAnniversary = true
                        }
                        .font(.luckySubheadlineStrong)
                        .foregroundStyle(Color.luckyBlue)
                        .underline()
                    }
                }
            }
        }
        .luckyBackButton()
        .task { await loadCode() }
        .navigationDestination(isPresented: $navigateToAnniversary) {
            AnniversaryView()
        }
    }
}

private extension ShareCodePairingView {
    func loadCode() async {
        isLoading = true
        loadFailed = false
        do {
            code = try await CoupleService.getMyInvitationCode().code
        } catch is CancellationError {
        } catch let error as URLError where error.code == .cancelled {
        } catch {
            loadFailed = true
        }
        isLoading = false
    }
}

#Preview {
    ShareCodePairingView()
        .environment(AppState())
}
