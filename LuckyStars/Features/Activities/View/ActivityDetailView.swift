//
//  ActivityDetailView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity

    @State private var selectedDate = Date.now
    @State private var selectedTime = Date.now
    @State private var isFavorite = false
    @State private var isLoadingFavorite = false
    @State private var isProposing = false
    @State private var proposalSuccess = false
    @State private var errorMessage: String? = nil
    @State private var showNoPartnerAlert = false
    @State private var showProposalSent = false
    @State private var partnerName = "your partner"
    @Environment(\.dismiss) private var dismiss
    @Environment(\.switchTab) private var switchTab
    @State private var showInvitePartner = false

    var body: some View {
        Background {
            ScrollView {
                VStack(spacing: Spacing.xl) {

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(activity.categoryName)
                                .font(.luckyBody)
                                .foregroundStyle(Color.charcoal.opacity(0.7))
                                .kerning(1)

                            Text(activity.title)
                                .font(.luckyTitle)
                                .foregroundStyle(Color.charcoal)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Image(activity.category.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)

                    VStack(alignment: .leading, spacing: Spacing.l) {

                        InfoTags(activity: activity)

                        Text(activity.description)
                            .font(.luckyBody)
                            .foregroundStyle(Color.charcoal)
                            .padding(.vertical, 14)

                        Rectangle().fill(Color.rowDivider).frame(height: 1)

                        HStack {
                            Text("Pick a date")
                                .font(.luckyLabel)
                                .foregroundStyle(Color.charcoal)
                            Spacer()
                            DatePicker("", selection: $selectedDate, in: Date.now..., displayedComponents: .date)
                                .labelsHidden()
                                .tint(Color.luckyBlue)
                        }

                        Rectangle().fill(Color.rowDivider).frame(height: 1)

                        HStack {
                            Text("Pick a time")
                                .font(.luckyLabel)
                                .foregroundStyle(Color.charcoal)
                            Spacer()
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .tint(Color.luckyBlue)
                        }
                        .padding(.bottom, Spacing.s)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.luckySubheadline)
                                .foregroundStyle(Color.destructiveRed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button("Propose this activity", action: proposeActivity)
                            .buttonStyle(.luckyPrimary)
                            .disabled(proposalSuccess)
                            .luckyLoading(isProposing)

                        Button(action: toggleFavorite) {
                            HStack(spacing: Spacing.s) {
                                Text(isFavorite ? "Saved to favorites" : "Save to favorites")
                                FavoriteStar(isFilled: isFavorite)
                            }
                        }
                        .buttonStyle(.luckySecondary)
                        .luckyLoading(isLoadingFavorite)
                    }
                    .padding(20)
                    .luckyCard()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .luckyBackButton()
        .alert("No Partner Paired", isPresented: $showNoPartnerAlert) {
            Button("Cancel", role: .cancel) { }
            // The default action is shown in bold, so "Invite" stands out from "Cancel".
            Button("Invite") { showInvitePartner = true }
                .keyboardShortcut(.defaultAction)
        } message: {
            Text("You haven't paired with a partner yet. Would you like to invite them?")
        }
        .fullScreenCover(isPresented: $showProposalSent) {
            ProposalSentView(
                partnerName: partnerName,
                onBackToActivities: {
                    showProposalSent = false
                    dismiss()
                },
                onGoToDashboard: {
                    showProposalSent = false
                    dismiss()
                    switchTab(.dashboard)
                }
            )
        }
        .navigationDestination(isPresented: $showInvitePartner) {
            ShareCodePairingView(showsNext: false)
        }
        .task {
            do {
                let favorites = try await ActivityService.fetchFavorites()
                isFavorite = favorites.contains(where: { $0.id == activity.id })
            } catch {
                guard !error.isCancellation else { return }
                print("Fetch favorites error: \(error)")
                errorMessage = "Couldn't check your favorites."
            }
        }
    }

    // MARK: - Actions
    private func proposeActivity() {
        Task {
            errorMessage = nil

            // A proposal needs a partner to answer it: offer to invite one instead of failing.
            isProposing = true
            guard await partnerHasJoined() else {
                isProposing = false
                return
            }

            let finalDate = combinedDate(date: selectedDate, time: selectedTime)
            guard finalDate > .now else {
                errorMessage = "Pick a date and time in the future."
                isProposing = false
                return
            }

            do {
                _ = try await PlannedActivityService.propose(activityId: activity.id, date: finalDate)
                proposalSuccess = true
                showProposalSent = true
            } catch let error as APIError {
                print("Propose error: \(error)")
                errorMessage = error.errorDescription ?? "Couldn't send the proposal. Please try again."
            } catch {
                print("Propose error: \(error)")
                errorMessage = "Couldn't send the proposal. Please try again."
            }
            isProposing = false
        }
    }

    /// False (and the invite prompt shown, or an error set) when the plan can't go ahead yet.
    private func partnerHasJoined() async -> Bool {
        do {
            let couple = try await ProfileService.fetchCouple()
            guard let partner = couple.partner else {
                showNoPartnerAlert = true
                return false
            }
            partnerName = partner.firstName
            return true
        } catch let error as APIError {
            if case .serverError(404, _) = error {
                showNoPartnerAlert = true
            } else {
                errorMessage = "Couldn't send the proposal. Please try again."
            }
            return false
        } catch {
            if !error.isCancellation {
                errorMessage = "Couldn't send the proposal. Please try again."
            }
            return false
        }
    }

    private func toggleFavorite() {
        guard !isLoadingFavorite else { return }
        Task {
            isLoadingFavorite = true
            errorMessage = nil
            do {
                if isFavorite {
                    try await ActivityService.removeFavorite(activityId: activity.id)
                } else {
                    try await ActivityService.addFavorite(activityId: activity.id)
                }
                withAnimation { isFavorite.toggle() }
            } catch {
                print("Favorite toggle error: \(error)")
                errorMessage = "Couldn't update your favorites. Please try again."
            }
            isLoadingFavorite = false
        }
    }

    // MARK: - Helpers
    private func combinedDate(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return calendar.date(from: components) ?? date
    }
}

#Preview {
    let activity = Activity(
        id: UUID(),
        title: "Pottery Workshop",
        description: "Create something meaningful side by side.",
        budget: "€€€",
        duration: 180,
        isIndoor: true,
        categoryId: UUID(),
        categoryName: "Creative"
    )
    NavigationStack {
        ActivityDetailView(activity: activity)
    }
}
