//
//  TabBar.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 20/02/2026.
//

import SwiftUI

enum AppTab: CaseIterable {
    case dashboard, discover, myDates, profile

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .discover: "Discover"
        case .myDates: "My Dates"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "star"
        case .discover: "sparkle.magnifyingglass"
        case .myDates: "heart"
        case .profile: "person"
        }
    }
}

/// Lets a screen inside a tab (like the Dashboard shortcuts) switch to another tab.
private struct SwitchTabKey: EnvironmentKey {
    static let defaultValue: (AppTab) -> Void = { _ in }
}

extension EnvironmentValues {
    var switchTab: (AppTab) -> Void {
        get { self[SwitchTabKey.self] }
        set { self[SwitchTabKey.self] = newValue }
    }
}

struct TabBar: View {

    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: AppTab.dashboard.icon, value: .dashboard) {
                DashboardView()
                    .toolbarVisibility(.hidden, for: .tabBar)
            }

            Tab("Discover", systemImage: AppTab.discover.icon, value: .discover) {
                ActivityView()
                    .toolbarVisibility(.hidden, for: .tabBar)
            }

            Tab("My Dates", systemImage: AppTab.myDates.icon, value: .myDates) {
                MyDatesView()
                    .toolbarVisibility(.hidden, for: .tabBar)
            }

            Tab("Profile", systemImage: AppTab.profile.icon, value: .profile) {
                ProfileView()
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
        .environment(\.switchTab, { selectedTab = $0 })
        // The system bar is hidden inside each tab; the Lucky Stars pill below replaces it.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            LuckyTabBar(selection: $selectedTab)
        }
    }
}

// MARK: - Custom bar

private struct LuckyTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .regular))
                            .frame(height: 26)

                        Text(tab.title)
                            .font(selection == tab ? .luckySubheadlineStrong : .luckySubheadline)
                    }
                    .foregroundStyle(selection == tab ? Color.luckyBlue : Color.inkSecondary)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .luckyOutline(Capsule(), shadowOffset: 0)
        .padding(.horizontal, 10)
        .padding(.bottom, 4)
    }
}

#Preview {
    TabBar()
        .environment(AppState())
}
