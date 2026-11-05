//
//  AboutYouView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct AboutYouView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var name = ""
    @State private var email = ""
    @State private var showDeleteAccountAlert = false
    @Environment(AppState.self) private var appState

    var body: some View {
        Background {
            ScrollView {
                VStack(spacing: 20) {
                    LuckyGroup {
                        HStack {
                            Text("Name")
                                .font(.luckyBodyStrong)
                                .foregroundStyle(Color.charcoal)
                            Spacer()
                            TextField("", text: $name, prompt: Text("Enter your name").foregroundStyle(Color.placeholderGrey))
                                .multilineTextAlignment(.trailing)
                                .font(.luckyBody)
                                .foregroundStyle(Color.inkSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)

                        HStack {
                            Text("Email")
                                .font(.luckyBodyStrong)
                                .foregroundStyle(Color.charcoal)
                            Spacer()
                            TextField("", text: $email, prompt: Text("Enter your email").foregroundStyle(Color.placeholderGrey))
                                .multilineTextAlignment(.trailing)
                                .font(.luckyBody)
                                .foregroundStyle(Color.inkSecondary)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)
                    }

                    LuckyGroup {
                        NavigationLink {
                            ForgotPasswordView()
                        } label: {
                            SettingsRow(title: "Reset password")
                        }
                    }

                    if let error = viewModel.saveError {
                        Text(error)
                            .font(.luckySubheadline)
                            .foregroundStyle(Color.destructiveRed)
                    }

                    if let error = viewModel.deleteError {
                        Text(error)
                            .font(.luckySubheadline)
                            .foregroundStyle(Color.destructiveRed)
                    }

                    Button("Save") {
                        Task {
                            await viewModel.saveProfile(firstName: name, email: email)
                        }
                    }
                    .buttonStyle(.luckyPrimary)
                    .luckyLoading(viewModel.isSaving)
                    .padding(.trailing, Outline.shadowOffset)

                    Button {
                        showDeleteAccountAlert = true
                    } label: {
                        Text("Delete Account")
                    }
                    .buttonStyle(.luckyDestructive)
                    .luckyLoading(viewModel.isDeleting)
                    .padding(.trailing, Outline.shadowOffset)
                }
                .padding(.horizontal, 20)
                .padding(.top, 90)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .luckyBackButton(title: "About You")
        .task {
            await viewModel.load()
            name = viewModel.user?.firstName ?? ""
            email = viewModel.user?.email ?? ""
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: deleteAccount)
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }

    // MARK: - Actions
    private func deleteAccount() {
        Task {
            // Only log out if the account was actually deleted —
            // otherwise stay here so the user can see the error.
            if await viewModel.deleteAccount() {
                appState.logout()
            }
        }
    }
}

#Preview {
    AboutYouView()
        .environment(AppState())
}
