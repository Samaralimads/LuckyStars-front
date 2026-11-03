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
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
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

                        if proposalSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Proposal sent to your partner!")
                                    .font(.luckySubheadlineStrong)
                            }
                            .foregroundStyle(Color.luckyBlue)
                        }

                        Button(isProposing ? "Sending..." : "Plan this activity", action: proposeActivity)
                            .buttonStyle(.luckyPrimary)
                            .disabled(isProposing)

                        Button(action: toggleFavorite) {
                            HStack(spacing: Spacing.s) {
                                Text(isFavorite ? "Saved to favorites" : "Save to favorites")
                                FavoriteStar(isFilled: isFavorite)
                            }
                        }
                        .buttonStyle(.luckySecondary)
                        .disabled(isLoadingFavorite)
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
        .task {
            do {
                let favorites = try await ActivityService.fetchFavorites()
                isFavorite = favorites.contains(where: { $0.id == activity.id })
            } catch {
                print("Fetch favorites error: \(error)")
            }
        }
    }

    // MARK: - Actions
    private func proposeActivity() {
        Task {
            isProposing = true
            let finalDate = combinedDate(date: selectedDate, time: selectedTime)

            do {
                _ = try await PlannedActivityService.propose(activityId: activity.id, date: finalDate)
                proposalSuccess = true
            } catch {
                print("Propose error: \(error)")
            }
            isProposing = false
        }
    }

    private func toggleFavorite() {
        guard !isLoadingFavorite else { return }
        Task {
            isLoadingFavorite = true
            do {
                if isFavorite {
                    try await ActivityService.removeFavorite(activityId: activity.id)
                } else {
                    try await ActivityService.addFavorite(activityId: activity.id)
                }
                withAnimation { isFavorite.toggle() }
            } catch {
                print("Favorite toggle error: \(error)")
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
