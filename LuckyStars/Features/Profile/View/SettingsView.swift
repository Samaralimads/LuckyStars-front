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
    @Environment(\.openURL) private var openURL
    @State private var showLogoutAlert = false
    @State private var showNoMailAlert = false

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
                        Button(action: contactSupport) {
                            SettingsRow(title: "Help & Support", subtitle: "Questions? Write to us")
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
        .alert("Contact support", isPresented: $showNoMailAlert) {
            Button("Copy email address") { UIPasteboard.general.string = AppLinks.supportEmail }
            Button("OK", role: .cancel) { }
        } message: {
            Text("We couldn't open Mail on this device. You can write to us at \(AppLinks.supportEmail).")
        }
    }

    // MARK: - Support
    /// Opens a new email to support, with the app and iOS version so we can help faster.
    /// Nothing personal is added to it.
    private func contactSupport() {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        let device = UIDevice.current

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = AppLinks.supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Lucky Stars support"),
            URLQueryItem(name: "body", value: """


                ---
                Lucky Stars \(version) (\(build))
                \(device.systemName) \(device.systemVersion)
                """)
        ]

        guard let url = components.url else {
            showNoMailAlert = true
            return
        }
        openURL(url) { accepted in
            // No Mail account set up (for example on the simulator): show the address instead.
            if !accepted { showNoMailAlert = true }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
