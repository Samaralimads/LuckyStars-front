//
//  SignupView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct SignUpView: View {
    @State private var viewModel = AuthViewModel()

    @Environment(AppState.self) private var appState

    var body: some View {
        Background {
            WhiteCard(title: "Create Your Account", description: "Sign up to begin planning meaningful moments as a couple.") {

                VStack(spacing: Spacing.s) {
                    InputField(
                        placeholder: "Name",
                        type: .name,
                        text: $viewModel.name,
                        isValid: viewModel.isNameValid
                    )

                    InputField(
                        placeholder: "Date of Birth",
                        date: $viewModel.birthDate,
                        maximumDate: AuthViewModel.latestBirthDate
                    )

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
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                Button("Sign Up") {
                    Task { await viewModel.signUp(appState: appState) }
                }
                .buttonStyle(.luckyPrimary)
                .disabled(!viewModel.canSignUp)

                OrDivider()

                AppleSignInButton(title: "Sign up with Apple") {
                    // TODO: Sign up with Apple
                }

                HStack(spacing: Spacing.xs) {
                    Text("Already have an account?")
                        .foregroundStyle(Color.inkSecondary)
                    NavigationLink("Sign in") {
                        SignInView()
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
    }
}

#Preview {
    SignUpView()
        .environment(AppState())
}
