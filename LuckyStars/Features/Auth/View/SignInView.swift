//
//  SigninView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct SignInView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showForgotPassword = false
    @Environment(AppState.self) private var appState

    var body: some View {
        Background {
            WhiteCard(title: "Welcome Back!", description: "Sign in to continue building memories and discovering new activities together.") {

                VStack(spacing: Spacing.s) {
                    InputField(
                        placeholder: "Email",
                        type: .email,
                        text: $viewModel.email,
                        isValid: viewModel.isEmailValid
                    )

                    InputField(
                        placeholder: "Password",
                        type: .password,
                        text: $viewModel.password,
                        isValid: viewModel.isPasswordValid,
                        passwordRequirements: PasswordRequirements(
                            hasUppercase: viewModel.hasUppercase,
                            hasNumber: viewModel.hasNumber,
                            hasMinLength: viewModel.hasMinLength
                        )
                    )

                    HStack {
                        Spacer()
                        Button("Forgot your password?") {
                            showForgotPassword = true
                        }
                        .font(.luckySubheadlineStrong)
                        .foregroundStyle(Color.luckyBlue)
                        .zIndex(1)
                    }
                    .padding(.trailing, Spacing.xs)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                Button("Sign In") {
                    Task { await viewModel.signIn(appState: appState) }
                }
                .buttonStyle(.luckyPrimary)
                .disabled(!viewModel.canSignIn)

                OrDivider()

                AppleSignInButton(title: "Sign in with Apple") {
                    // TODO: Sign in with Apple
                }

                HStack(spacing: Spacing.xs) {
                    Text("Already have an account?")
                        .foregroundStyle(Color.inkSecondary)
                    NavigationLink("Sign up") {
                        SignUpView()
                            .navigationBarBackButtonHidden(true)
                    }
                    .foregroundStyle(Color.luckyBlue)
                    .fontWeight(.bold)
                    .underline()
                }
                .font(.luckySubheadline)
            }
        }
        .luckyBackButton()
        .navigationDestination(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

#Preview {
    SignInView()
        .environment(AppState())
}
