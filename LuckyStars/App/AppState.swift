//
//  AppState.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 18/05/2026.
//

import Foundation

@Observable
class AppState {
    var isAuthenticated: Bool = JWTService.getToken() != nil
    var isOnboarding: Bool = UserDefaults.standard.bool(forKey: "isOnboarding")

    init() {
        NotificationCenter.default.addObserver(
            forName: .sessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.logout()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    func completeOnboarding() {
        isOnboarding = false
        UserDefaults.standard.set(false, forKey: "isOnboarding")
    }

    func logout() {
        AuthService.logout()
        isAuthenticated = false
        isOnboarding = false
        UserDefaults.standard.set(false, forKey: "isOnboarding")
    }
}
