//
//  ResetCodeView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI
import Combine

struct ResetCodeView: View {
    let email: String
    @State private var code: String = ""
    @State private var verifiedCode: String = ""
    @State private var timeRemaining: Int = 600
    @State private var timerExpired: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var navigateToReset = false
    @FocusState private var isFocused: Bool

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Background {
            WhiteCard(
                title: "Reset Password",
                description: "A 6-digit code was sent to \(email)"
            ) {
                HStack(spacing: Spacing.s) {
                    ForEach(0..<6) { index in
                        CodeDigitBox(
                            digit: digit(at: index),
                            isActive: code.count == index
                        )
                    }
                }
                .padding(.vertical, Spacing.l)
                .onTapGesture { isFocused = true }

                if let error = errorMessage {
                    Text(error)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                if timerExpired {
                    Button("Resend code") {
                        Task {
                            do {
                                try await AuthService.forgotPassword(email: email)
                                timeRemaining = 600
                                timerExpired = false
                                code = ""
                                errorMessage = nil
                            } catch {
                                print("Resend code error: \(error)")
                                errorMessage = "Something went wrong. Please try again."
                            }
                        }
                    }
                    .font(.luckySubheadlineStrong)
                    .foregroundStyle(Color.luckyBlue)
                } else {
                    (Text("Code valid for ").foregroundColor(Color.inkSecondary)
                     + Text(formattedTime).foregroundColor(Color.luckyBlue))
                        .font(.luckySubheadline)
                        .contentTransition(.numericText())
                }

                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .opacity(0)
                    .frame(height: 0)
            }
        }
        .luckyBackButton()
        .onAppear { isFocused = true }
        .onChange(of: code) { _, newValue in
            if newValue.count > 6 {
                code = String(newValue.prefix(6))
            }
            if newValue.count == 6 {
                isFocused = false
                Task {
                    isLoading = true
                    errorMessage = nil
                    do {
                        try await AuthService.verifyCode(email: email, code: newValue)
                        verifiedCode = newValue
                        navigateToReset = true
                    } catch {
                        print("Verify code error: \(error)")
                        errorMessage = "Invalid or expired code. Please try again."
                    }
                    isLoading = false
                }
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timerExpired = true
            }
        }
        .navigationDestination(isPresented: $navigateToReset) {
            ResetPasswordView(email: email, code: verifiedCode)
        }
    }

    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let stringIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[stringIndex])
    }
}

#Preview {
    ResetCodeView(email: "samara@test.com")
}
