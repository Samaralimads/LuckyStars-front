//
//  AppState.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/05/2026.
//

import Foundation

@Observable
class AppState {
    var isAuthenticated: Bool
    var isOnboarding: Bool = UserDefaults.standard.bool(forKey: "isOnboarding")

    /// Goes up every time the user pairs or unpairs, so screens showing couple data can reload.
    var coupleVersion = 0

    @ObservationIgnored private var sessionObserver: NSObjectProtocol?

    init() {
        Self.clearSessionLeftByPreviousInstall()
        isAuthenticated = JWTService.hasUsableToken()

        if !isAuthenticated { JWTService.delete() }

        sessionObserver = NotificationCenter.default.addObserver(
            forName: .sessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.logout()
        }
    }

    deinit {
        if let sessionObserver {
            NotificationCenter.default.removeObserver(sessionObserver)
        }
    }

    func login() {
        isAuthenticated = true
        isOnboarding = false
    }

    func register() {
        isAuthenticated = true
        isOnboarding = true
        UserDefaults.standard.set(true, forKey: "isOnboarding")
    }

    func coupleChanged() {
        coupleVersion += 1
    }

    func completeOnboarding() {
        isOnboarding = false
        UserDefaults.standard.set(false, forKey: "isOnboarding")
    }

    func logout() {
        AuthService.logout()
        ProfileImageStore.clear()
        PartnerImageStore.clear()
        AnniversaryReminderStore.clear()
        CalendarEventStore.clear()
        UserDefaults.standard.removeObject(forKey: "inviteBannerDismissed")
        isAuthenticated = false
        isOnboarding = false
        UserDefaults.standard.set(false, forKey: "isOnboarding")
    }

    // MARK: - Fresh install
    /// Keychain items survive uninstalling the app, UserDefaults don't. On the first launch
    /// after a (re)install, a token from the previous install is stale, so drop it.
    private static func clearSessionLeftByPreviousInstall() {
        let key = "hasLaunchedBefore"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        JWTService.delete()
        UserDefaults.standard.set(true, forKey: key)
    }
}
