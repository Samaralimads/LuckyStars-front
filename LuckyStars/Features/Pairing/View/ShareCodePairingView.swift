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
    @State private var showShare = false

    // Outside onboarding, someone with no couple yet (for example after unpairing) first picks
    // the anniversary: the partner joins the couple that is created here.
    @State private var needsAnniversary = false
    @State private var anniversary: Date? = nil
    @State private var isCreatingCouple = false
    @State private var createError: String? = nil

    var body: some View {
        Background {
            if needsAnniversary {
                anniversaryCard
            } else {
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

                    Button {
                        showShare = true
                    } label: {
                        HStack(spacing: Spacing.s) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Code")
                        }
                    }
                    .buttonStyle(.luckyPrimary)

                    if showsNext {
                        Button("I'll do it later") {
                            navigateToAnniversary = true
                        }
                        .font(.luckySubheadlineStrong)
                        .foregroundStyle(Color.luckyBlue)
                        .underline()
                    }
                }
            }
            }
        }
        .luckyBackButton()
        .task { await loadCode() }
        .sheet(isPresented: $showShare) {
            ShareSheet(message: shareMessage, subject: "Join me on Lucky Stars") { shared in
                showShare = false
                // Once the code has been sent, carry on (during onboarding) without a tap on "Next".
                guard shared, showsNext else { return }
                Task {
                    // Let the share sheet finish closing before pushing the next screen.
                    try? await Task.sleep(for: .seconds(0.4))
                    navigateToAnniversary = true
                }
            }
            .presentationDetents([.medium, .large])
        }
        .navigationDestination(isPresented: $navigateToAnniversary) {
            AnniversaryView()
        }
    }
}

private extension ShareCodePairingView {
    /// What your partner receives: where to get the app, then what to do with the code.
    var shareMessage: String {
        """
        Join me on Lucky Stars ✨
        It's where we'll find and plan our dates together. Get it here:
        \(AppLinks.appStore.absoluteString)

        Create an account and enter my pairing code: \(code)
        """
    }

    var anniversaryCard: some View {
        WhiteCard(
            title: "Your anniversary",
            description: "Tell us the day you got together. Then you can share your code with your partner."
        ) {
            InputField(placeholder: "Anniversary date", date: $anniversary)

            if let createError {
                Text(createError)
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.destructiveRed)
                    .multilineTextAlignment(.center)
            }

            Button("Continue") {
                Task { await createCouple() }
            }
            .buttonStyle(.luckyPrimary)
            .disabled(anniversary == nil)
            .luckyLoading(isCreatingCouple)
        }
    }

    func createCouple() async {
        guard let anniversary else { return }
        isCreatingCouple = true
        createError = nil
        defer { isCreatingCouple = false }

        do {
            _ = try await CoupleService.createCouple(anniversaryDate: anniversary)
            needsAnniversary = false
            await loadCode()
        } catch {
            guard !error.isCancellation else { return }
            print("Create couple error: \(error)")
            createError = "Something went wrong. Please try again."
        }
    }

    func loadCode() async {
        isLoading = true
        loadFailed = false

        // Outside onboarding, find out whether this person has a couple at all.
        if !showsNext {
            do {
                _ = try await ProfileService.fetchCouple()
            } catch let error as APIError {
                if case .serverError(404, _) = error {
                    needsAnniversary = true
                    isLoading = false
                    return
                }
            } catch {
                // Any other problem: carry on and show the code.
            }
        }

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
