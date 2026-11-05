//
//  AddCodePairingView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 13/02/2026.
//

import SwiftUI

struct AddCodePairingView: View {
    @State private var code: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var navigateToPairingSuccess = false
    @FocusState private var isFocused: Bool

    var body: some View {
        Background {
            WhiteCard(title: "Have a pairing code?", description: "If your partner invited you to join them, enter their unique 6-digit pairing code below.") {

                HStack(spacing: Spacing.s) {
                    ForEach(0..<6) { index in
                        CodeDigitBox(
                            digit: digit(at: index),
                            isActive: code.count == index
                        )
                    }
                }
                .padding(.vertical, Spacing.l)

                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .opacity(0)
                    .frame(height: 0)

                if let error = errorMessage {
                    Text(error)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                Button("Confirm", action: confirmCode)
                    .buttonStyle(.luckyPrimary)
                    .disabled(code.count < 6)
                    .luckyLoading(isLoading)

                NavigationLink("I'm the first one here") {
                    ShareCodePairingView()
                }
                .font(.luckySubheadlineStrong)
                .foregroundStyle(Color.luckyBlue)
                .underline()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // Small delay so the keyboard appears after the transition settles
            try? await Task.sleep(for: .seconds(0.5))
            isFocused = true
        }
        .onChange(of: code) { _, newValue in
            // Codes are 6 digits: drop anything else (e.g. pasted text) and cap the length.
            let digits = String(newValue.filter(\.isNumber).prefix(6))
            if digits != newValue {
                code = digits
            }
        }
        .navigationDestination(isPresented: $navigateToPairingSuccess) {
            PairingSuccessfulView()
        }
    }

    // MARK: - Actions
    private func confirmCode() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                _ = try await CoupleService.joinCouple(invitationCode: code)
                navigateToPairingSuccess = true
            } catch let error as APIError {
                print("Join couple error: \(error)")
                errorMessage = error.errorDescription ?? "Invalid or expired code. Please check and try again."
            } catch {
                print("Join couple error: \(error)")
                errorMessage = "Invalid or expired code. Please check and try again."
            }
            isLoading = false
        }
    }

    // MARK: - Helpers
    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let stringIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[stringIndex])
    }
}

#Preview {
    AddCodePairingView()
        .environment(AppState())
}
