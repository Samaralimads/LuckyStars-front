//
//  SettingsView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.requestReview) var requestReview
    @Environment(AppState.self) private var appState
    @State private var showLogoutAlert = false

    var body: some View {
        Background {
            ScrollView {
                VStack(spacing: 20) {
                    LuckyGroup {
                        NavigationLink {
                            AboutYouView()
                        } label: {
                            SettingsRow(title: "About you", subtitle: "Your details and account")
                        }

                        NavigationLink {
                            AboutRelationshipView()
                        } label: {
                            SettingsRow(title: "Your relationship", subtitle: "Partner and anniversary")
                        }

                        NavigationLink {
                            NotificationView()
                        } label: {
                            SettingsRow(title: "Notification Settings", subtitle: "Choose what you hear about")
                        }
                    }

                    LuckyGroup {
                        Button {
                            // TODO: send email to support
                        } label: {
                            SettingsRow(title: "Help & Support", subtitle: "FAQs and contact")
                        }

                        Button {
                            requestReview()
                        } label: {
                            SettingsRow(title: "Leave us a review", subtitle: "Tell us what you think")
                        }
                    }

                    Button("Log out") {
                        showLogoutAlert = true
                    }
                    .buttonStyle(.luckyDestructive)
                    .padding(.trailing, Outline.shadowOffset)
                    .alert("Log Out", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Log out", role: .destructive) {
                            appState.logout()
                        }
                    } message: {
                        Text("Are you sure you want to log out?")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 90)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .luckyBackButton(title: "Settings")
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
