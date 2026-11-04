//
//  DashboardView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(\.switchTab) private var switchTab
    @State private var showInviteBannerDismissed = false
    @State private var proposalToReschedule: PlannedActivity? = nil
    @State private var proposalToDecline: PlannedActivity? = nil
    @State private var navigateToDetail = false
    @State private var detailActivity: Activity? = nil
    @State private var showNotifications = false

    var body: some View {
        @Bindable var viewModel = viewModel

        Background {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if !viewModel.isPaired && !showInviteBannerDismissed {
                        InviteBannerCard(
                            onDismiss: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    showInviteBannerDismissed = true
                                }
                            }
                        )
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.luckySubheadline)
                            .foregroundStyle(Color.destructiveRed)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }

                    if let nextDate = viewModel.nextDate {
                        NextDateCard(
                            planned: nextDate,
                            onDetails: { openDetails(for: nextDate) },
                            onAddToCalendar: { addToCalendar(nextDate) }
                        )
                    } else if viewModel.pendingProposals.isEmpty && viewModel.sentProposals.isEmpty {
                        EmptyNextDateCard()
                    }

                    ForEach(viewModel.pendingProposals) { proposal in
                        PendingProposalCard(
                            title: proposal.activityTitle,
                            date: proposal.parsedDate ?? Date.now,
                            partnerName: viewModel.partnerName,
                            note: proposal.note,
                            onAccept: { accept(proposal) },
                            onRefuse: { proposalToDecline = proposal },
                            onReschedule: { proposalToReschedule = proposal }
                        )
                    }

                    ForEach(viewModel.sentProposals) { proposal in
                        SentProposalCard(
                            title: proposal.activityTitle,
                            date: proposal.parsedDate ?? Date.now,
                            partnerName: viewModel.partnerName
                        )
                    }

                    WishlistSection(
                        favorites: viewModel.favorites,
                        onSeeAll: { switchTab(.myDates) },
                        onBrowse: { switchTab(.discover) }
                    )

                    DashboardShortcuts(
                        onBrowse: { switchTab(.discover) },
                        onManage: { switchTab(.myDates) }
                    )

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
                .dynamicTypeSize(.large ... .xxLarge)
            }
            .refreshable { await viewModel.load() }
        }
        .task { await viewModel.load() }
        .navigationDestination(isPresented: $showNotifications) {
            NotificationsFeedView()
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let activity = detailActivity {
                ActivityDetailView(activity: activity)
            }
        }
        .sheet(item: $proposalToReschedule) { proposal in
            RescheduleSheet(proposal: proposal, partnerName: viewModel.partnerName) { newDate, note in
                Task { await viewModel.reschedule(proposal: proposal, newDate: newDate, note: note) }
            }
        }
        .alert(
            "Decline Proposal",
            isPresented: Binding(
                get: { proposalToDecline != nil },
                set: { if !$0 { proposalToDecline = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { proposalToDecline = nil }
            Button("Decline", role: .destructive) {
                if let proposal = proposalToDecline {
                    decline(proposal)
                }
                proposalToDecline = nil
            }
        } message: {
            Text("Are you sure you want to decline this proposal? Your partner will be notified.")
        }
        .alert("Calendar Error", isPresented: $viewModel.showCalendarError) { } message: {
            Text(viewModel.calendarError ?? "")
        }
        .alert("Calendar", isPresented: $viewModel.showCalendarMessage) { } message: {
            Text(viewModel.calendarMessage ?? "")
        }
    }

    // MARK: - Actions
    private func openDetails(for planned: PlannedActivity) {
        Task {
            guard let activity = await viewModel.fetchActivity(id: planned.activityId) else { return }
            detailActivity = activity
            navigateToDetail = true
        }
    }

    private func addToCalendar(_ planned: PlannedActivity) {
        Task { await viewModel.addToCalendar(planned: planned) }
    }

    private func accept(_ proposal: PlannedActivity) {
        Task { await viewModel.accept(proposal: proposal) }
    }

    private func decline(_ proposal: PlannedActivity) {
        Task { await viewModel.decline(proposal: proposal) }
    }
}

// MARK: - Components
private extension DashboardView {

    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting.uppercased())
                    .font(.luckyCaptionStrong)
                    .foregroundStyle(Color.inkSecondary)
                    .kerning(1)
                Text(viewModel.firstName)
                    .font(.luckyTitle)
                    .foregroundStyle(Color.charcoal)
            }

            Spacer()

            // TODO: fill NotificationsFeedView with a real feed (partner responses, upcoming activities, special dates) — not NotificationView, that's just preference toggles
            LuckyCircleButton(systemName: "bell", label: "Notifications") { showNotifications = true }
                .padding(.trailing, Outline.shadowMin)
        }
    }
}

//#Preview {
//    NavigationStack {
//        DashboardView()
//    }
//}

#Preview("All Cards") {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    let nextDate = PlannedActivity(
        id: UUID(),
        activityId: UUID(),
        activityTitle: "Brunch at a local café",
        coupleId: UUID(),
        plannedByUserId: UUID(),
        proposedDate: dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 3, to: .now)!),
        responseDate: nil,
        bookingStatus: "accepted",
        reminderEnabled: true,
        reminderDaysBefore: 1,
        note: nil,
        createdAt: nil
    )

    return NavigationStack {
        Background {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GOOD EVENING")
                            .font(.luckyCaptionStrong)
                            .foregroundStyle(Color.inkSecondary)
                            .kerning(1)
                        Text("Sarah")
                            .font(.luckyTitle)
                            .foregroundStyle(Color.charcoal)
                    }

                    InviteBannerCard(code: "C89FB7", onDismiss: {})

                    NextDateCard(planned: nextDate, onDetails: {}, onAddToCalendar: {})

                    EmptyNextDateCard()

                    PendingProposalCard(
                        title: "Sunset boat tour",
                        date: Calendar.current.date(byAdding: .day, value: 5, to: .now)!,
                        partnerName: "Henri",
                        note: "How about this instead?",
                        onAccept: {},
                        onRefuse: {},
                        onReschedule: {}
                    )

                    SentProposalCard(
                        title: "Pottery Workshop",
                        date: Calendar.current.date(byAdding: .day, value: 3, to: .now)!,
                        partnerName: "Henri"
                    )

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
                .dynamicTypeSize(.large ... .xxLarge)
            }
        }
    }
}
