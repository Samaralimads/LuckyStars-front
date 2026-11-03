//
//  LuckyStarsApp.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 09/02/2026.
//

import SwiftUI

@main
struct LuckyStarsApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if !appState.isAuthenticated {
                NavigationStack {
                    WelcomeView()
                }
                .environment(appState)
            } else if appState.isOnboarding {
                NavigationStack {
                    AddCodePairingView()
                }
                .environment(appState)
            } else {
                NavigationStack {
                    TabBar()
                }
                .environment(appState)
            }
        }
    }
}
