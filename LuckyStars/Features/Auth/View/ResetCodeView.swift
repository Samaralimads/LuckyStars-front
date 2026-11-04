//
//  ResetCodeView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct ResetCodeView: View {
    let email: String
    @State private var code: String = ""
    @State private var verifiedCode: String = ""
    @State private var deadline = Date.now.addingTimeInterval(Self.codeLifetime)
    @State private var now = Date.now
    @State private var isResending = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var navigateToReset = false
    @FocusState private var isFocused: Bool

    private static let codeLifetime: TimeInterval = 600

    private var timeRemaining: Int {
        max(0, Int(deadline.timeIntervalSince(now).rounded(.up)))
    }

    private var timerExpired: Bool { timeRemaining == 0 }

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
                    Button(isResending ? "Sending..." : "Resend code") {
                        Task {
                            isResending = true
                            defer { isResending = false }
                            do {
                                try await AuthService.forgotPassword(email: email)
                                deadline = Date.now.addingTimeInterval(Self.codeLifetime)
                                now = .now
                                code = ""
                                errorMessage = nil
                            } catch {
                                print("Resend code error: \(error)")
                                errorMessage = "Something went wrong. Please try again."
                            }
                        }
                    }
                    .disabled(isResending)
                    .font(.luckySubheadlineStrong)
                    .foregroundStyle(Color.luckyBlue)
                } else {
                    Text("Code valid for \(Text(formattedTime).foregroundStyle(Color.luckyBlue))")
                        .foregroundStyle(Color.inkSecondary)
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
        .task {
            while !Task.isCancelled {
                now = .now
                try? await Task.sleep(for: .seconds(1))
            }
        }
        .onChange(of: code) { _, newValue in
            // Codes are 6 digits: drop anything else (e.g. pasted text) and cap the length.
            let digits = String(newValue.filter(\.isNumber).prefix(6))
            if digits != newValue {
                code = digits
                return
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
