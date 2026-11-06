//
//  CompleteAppleProfileView.swift
//  LuckyStars
//
//  Shown to someone signing in with Apple for the first time: Apple doesn't give us a birth date
//  (and sometimes no name), so we ask for them before the account is created.
//

import SwiftUI

struct CompleteAppleProfileView: View {
    let info: AppleCredentialInfo
    let viewModel: AppleSignInViewModel

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var birthDate: Date? = nil
    @State private var errorMessage: String? = nil
    @State private var isSaving = false

    init(info: AppleCredentialInfo, viewModel: AppleSignInViewModel) {
        self.info = info
        self.viewModel = viewModel
        self._firstName = State(initialValue: info.firstName ?? "")
    }

    private var isValid: Bool {
        firstName.trimmingCharacters(in: .whitespaces).count >= 2 && birthDate != nil
    }

    var body: some View {
        Background {
            WhiteCard(
                title: "Almost there!",
                description: "Tell us a little about you to finish creating your account."
            ) {
                VStack(spacing: Spacing.s) {
                    InputField(
                        placeholder: "Name",
                        type: .name,
                        text: $firstName,
                        isValid: firstName.trimmingCharacters(in: .whitespaces).count >= 2
                    )

                    InputField(
                        placeholder: "Date of Birth",
                        date: $birthDate
                    )
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.luckySubheadline)
                        .foregroundStyle(Color.destructiveRed)
                        .multilineTextAlignment(.center)
                }

                Button("Continue") {
                    Task {
                        isSaving = true
                        errorMessage = await viewModel.send(
                            info,
                            firstName: firstName.trimmingCharacters(in: .whitespaces),
                            birthDate: birthDate,
                            appState: appState
                        )
                        isSaving = false
                    }
                }
                .buttonStyle(.luckyPrimary)
                .disabled(!isValid)
                .luckyLoading(isSaving)

                Button("Cancel") { dismiss() }
                    .font(.luckySubheadlineStrong)
                    .foregroundStyle(Color.luckyBlue)
                    .underline()
            }
        }
        .presentationDetents([.large])
    }
}
