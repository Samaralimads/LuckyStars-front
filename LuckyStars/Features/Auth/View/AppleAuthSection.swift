//
//  AppleAuthSection.swift
//  LuckyStars
//
//  The "Sign in / Sign up with Apple" button, its error message, and the "finish your profile"
//  sheet for first-time Apple users. Used on the Sign In and Sign Up screens.
//

import AuthenticationServices
import SwiftUI

struct AppleAuthSection: View {
    enum Kind {
        case signIn, signUp
    }

    let kind: Kind

    @Environment(AppState.self) private var appState
    @State private var viewModel = AppleSignInViewModel()

    var body: some View {
        VStack(spacing: Spacing.s) {
            SignInWithAppleButton(kind == .signIn ? .signIn : .signUp) { request in
                viewModel.configure(request)
            } onCompletion: { result in
                Task { await viewModel.handle(result, appState: appState) }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 48)
            .clipShape(Capsule())
            // Same outline as the other outlined buttons. (The system's own outline got cut at the corners.)
            .overlay(Capsule().strokeBorder(Color.charcoal, lineWidth: Outline.thick))
            .overlay {
                if viewModel.isLoading {
                    Capsule().fill(Color.cardFill)
                    ProgressView().tint(Color.charcoal)
                }
            }
            .disabled(viewModel.isLoading)

            if let message = viewModel.errorMessage, viewModel.pendingProfile == nil {
                Text(message)
                    .font(.luckySubheadline)
                    .foregroundStyle(Color.destructiveRed)
                    .multilineTextAlignment(.center)
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.pendingProfile != nil },
            set: { if !$0 { viewModel.pendingProfile = nil } }
        )) {
            if let info = viewModel.pendingProfile {
                CompleteAppleProfileView(info: info, viewModel: viewModel)
            }
        }
    }
}
