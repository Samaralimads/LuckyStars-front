//
//  ShareCodePairingView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 13/02/2026.
//

import SwiftUI

struct ShareCodePairingView: View {
    @State private var code = ""
    @State private var isLoading = true
    @State private var navigateToAnniversary = false

    var body: some View {
        Background {
            WhiteCard(title: "First one here?", description: "Share this code with your partner to connect your accounts and start planning activities together.") {

                if isLoading {
                    ProgressView()
                        .padding(.vertical, Spacing.xl)
                } else {
                    HStack(spacing: Spacing.s) {
                        ForEach(Array(code), id: \.self) { character in
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

                    Button("Next") {
                        navigateToAnniversary = true
                    }
                    .font(.luckySubheadlineStrong)
                    .foregroundStyle(Color.luckyBlue)
                    .underline()
                }
            }
        }
        .luckyBackButton()
        .task {
            do {
                let invitation = try await CoupleService.getMyInvitationCode()
                code = invitation.code
            } catch {
                code = "------"
            }
            isLoading = false
        }
        .navigationDestination(isPresented: $navigateToAnniversary) {
            AnniversaryView()
        }
    }
}

#Preview {
    ShareCodePairingView()
        .environment(AppState())
}
