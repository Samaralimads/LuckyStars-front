//
//  ForgotPasswordView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 11/02/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel = AuthViewModel()
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var navigateToCode = false

    var body: some View {
        Background {
            WhiteCard(title: "Forgot your password?", description: "We will send a reset code to the email entered below:") {

                InputField(
                    placeholder: "Email",
                    type: .email,
                    text: $viewModel.email,
                    isValid: viewModel.isEmailValid
                )
                .padding(.top, Spacing.xl)

                if let error = errorMessage {
                    Text(error)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                Button(isLoading ? "Sending..." : "Reset Password") {
                    Task {
                        isLoading = true
                        errorMessage = nil
                        do {
                            try await AuthService.forgotPassword(email: viewModel.email)
                            navigateToCode = true
                        } catch {
                            print("Forgot password error: \(error)")
                            errorMessage = "Something went wrong. Please try again."
                        }
                        isLoading = false
                    }
                }
                .buttonStyle(.luckyPrimary)
                .disabled(!viewModel.isEmailValid || isLoading)
            }
        }
        .luckyBackButton()
        .navigationDestination(isPresented: $navigateToCode) {
            ResetCodeView(email: viewModel.email)
        }
    }
}

#Preview {
    ForgotPasswordView()
}
