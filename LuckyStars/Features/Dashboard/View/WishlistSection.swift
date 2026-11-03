//
//  WishlistSection.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  "Our wishlist": the activities you've favorited, with a link to see them all.
//

import SwiftUI

struct WishlistSection: View {
    let favorites: [Activity]
    let onSeeAll: () -> Void
    let onBrowse: () -> Void

    private let maxRows = 3

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text("Our wishlist")
                    .font(.luckyHeadline)
                    .foregroundStyle(Color.charcoal)

                Spacer()

                Button(action: onSeeAll) {
                    Text("see all →")
                        .font(.luckyLabel)
                        .foregroundStyle(Color.charcoal)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, Spacing.xs)

            if favorites.isEmpty {
                emptyState
            } else {
                ForEach(favorites.prefix(maxRows)) { activity in
                    NavigationLink(destination: ActivityDetailView(activity: activity)) {
                        row(for: activity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func row(for activity: Activity) -> some View {
        HStack(spacing: Spacing.m) {
            Image(activity.category.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            Text(activity.title)
                .font(.luckyLabel)
                .foregroundStyle(Color.charcoal)
                .lineLimit(1)

            Spacer(minLength: 0)
            
            FavoriteStar()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .luckyCard()
        .padding(.trailing, Outline.shadowOffset)
    }

    // TODO: Replace the star with a cute illustration or animation.
    private var emptyState: some View {
        Button(action: onBrowse) {
            HStack(spacing: Spacing.m) {
                Image(systemName: "star")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.charcoal)

                Text("Favorite an activity and it will show up here")
                    .font(.luckyBody)
                    .foregroundStyle(Color.inkSecondary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.charcoal, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            )
            .padding(.trailing, Outline.shadowOffset)
        }
        .buttonStyle(.plain)
    }
}

/// The two shortcut cards under the wishlist: Browse ideas and Manage dates.
struct DashboardShortcuts: View {
    let onBrowse: () -> Void
    let onManage: () -> Void

    var body: some View {
        HStack(spacing: Spacing.m) {
            shortcut(title: "Browse ideas", action: onBrowse) {
                Image(systemName: "safari")
                    .foregroundStyle(Color.luckyBlue)
            }

            shortcut(title: "Manage dates", action: onManage) {
                CalendarHeartIcon(color: .avatarPink)
            }
        }
        .padding(.trailing, Outline.shadowOffset)
    }

    private func shortcut<Icon: View>(title: String, action: @escaping () -> Void, @ViewBuilder icon: () -> Icon) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                icon()
                    .font(.system(size: 24))

                Text(title)
                    .font(.luckyLabel)
                    .foregroundStyle(Color.charcoal)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .luckyCard()
        }
        .buttonStyle(.plain)
    }
}

/// A simple outlined calendar with a heart in it (SF Symbols has no such symbol).
private struct CalendarHeartIcon: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .strokeBorder(color, lineWidth: 2)
            .frame(width: 26, height: 24)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(color)
                    .frame(height: 2)
                    .padding(.top, 6)
            }
            .overlay(alignment: .bottom) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(color)
                    .padding(.bottom, 4)
            }
            .overlay(alignment: .top) {
                HStack(spacing: 10) {
                    Capsule().fill(color).frame(width: 2.5, height: 7)
                    Capsule().fill(color).frame(width: 2.5, height: 7)
                }
                .offset(y: -3)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    Background {
        VStack(spacing: 20) {
            WishlistSection(favorites: [], onSeeAll: {}, onBrowse: {})
            DashboardShortcuts(onBrowse: {}, onManage: {})
        }
        .padding(20)
    }
}
