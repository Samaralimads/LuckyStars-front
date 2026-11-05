//
//  ProfileView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 12/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var showSettings = false
    @State private var showNoPairAlert = false
    @State private var showInvitePartner = false
    @State private var showEditAnniversary = false
    @State private var showAddDate = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var anniversary = Date()
    @State private var anniversaryReminder = AnniversaryReminderStore.load()

    var body: some View {
        Background {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(Color.charcoal)
                                .frame(width: 48, height: 48)
                                .luckyOutline(Circle())
                                .padding(.trailing, Outline.shadowMin)
                        }
                        .accessibilityLabel("Settings")
                    }
                    .padding(.bottom, -36)

                    VStack(spacing: 12) {
                        ProfileAvatarsCard(
                            partner1Initial: viewModel.partner1Initial,
                            partner2Initial: viewModel.partner2Initial,
                            profileImage: selectedImage,
                            onCameraClick: {
                                showImagePicker = true
                            },
                            onAddPartnerClick: {
                                if !viewModel.isPaired {
                                    showNoPairAlert = true
                                }
                            }
                        )

                        Text(viewModel.displayName)
                            .font(.luckyTitle)
                            .foregroundStyle(Color.charcoal)
                    }

                    TogetherForCard(anniversary: anniversary) {
                        showEditAnniversary = true
                    }

                    ImportantDatesCard(
                        anniversary: anniversary,
                        importantDates: $viewModel.importantDates,
                        onAddDate: { showAddDate = true },
                        onDelete: { date in Task { await viewModel.deleteImportantDate(date) } },
                        onEdit: { date in Task { await viewModel.updateImportantDate(date) } },
                        anniversaryReminderDaysBefore: $anniversaryReminder
                    )

                    StatsCard()

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
        }
        .task {
            await viewModel.load()
            anniversary = viewModel.anniversaryDate
            selectedImage = ProfileImageStore.load()
        }
        .onChange(of: anniversaryReminder) { _, newValue in
            AnniversaryReminderStore.save(newValue)
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: $showInvitePartner) {
            ShareCodePairingView(showsNext: false)
        }
        .alert("No Partner Paired", isPresented: $showNoPairAlert) {
            Button("Cancel", role: .cancel) { }
            // The default action is shown in bold, so "Invite" stands out from "Cancel".
            Button("Invite") { showInvitePartner = true }
                .keyboardShortcut(.defaultAction)
        } message: {
            Text("You haven't paired with a partner yet. Would you like to invite them?")
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showEditAnniversary) {
            EditAnniversarySheet(anniversary: $anniversary) { date in
                await viewModel.updateAnniversary(date)
            }
        }
        .sheet(isPresented: $showAddDate) {
            AddImportantDateSheet { label, date, repeatsYearly, reminderDaysBefore in
                Task {
                    await viewModel.addImportantDate(
                        label: label,
                        date: date,
                        repeatsYearly: repeatsYearly,
                        reminderDaysBefore: reminderDaysBefore
                    )
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    ProfileView()
}
