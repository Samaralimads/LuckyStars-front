//
//  AboutRelationshipView.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 13/02/2026.
//

import SwiftUI

struct AboutRelationshipView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var showEnterCode = false
    @Environment(\.switchTab) private var switchTab

    var body: some View {
        Background{

            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.isPaired {
                    PartnerView(viewModel: viewModel)
                } else {
                    NoPartnerView(onEnterCode: { showEnterCode = true })
                }
            }
        }
        .luckyBackButton(title: "Your Relationship")
        .task { await viewModel.load() }
        .fullScreenCover(isPresented: $showEnterCode, onDismiss: {
            Task { await viewModel.load() }
        }) {
            NavigationStack {
                AddCodePairingView(isOnboarding: false) {
                    showEnterCode = false
                    switchTab(.dashboard)
                }
            }
        }
    }
}


struct PartnerView: View {
    let viewModel: ProfileViewModel
    @State private var showUnpairAlert = false
    @State private var isUnpairing = false
    @State private var unpairError: String? = nil
    @Environment(AppState.self) private var appState

    var body: some View {

        ScrollView {
            VStack(spacing: 20) {
                LuckyGroup {
                    HStack {
                        Text("Partner")
                            .font(.luckyBodyStrong)
                            .foregroundStyle(Color.charcoal)

                        Spacer()

                        Text(viewModel.couple?.partner?.firstName ?? "")
                            .font(.luckyBody)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 22)

                    HStack {
                        Text("Together Since")
                            .font(.luckyBodyStrong)
                            .foregroundStyle(Color.charcoal)

                        Spacer()

                        Text(viewModel.anniversaryDate, style: .date)
                            .font(.luckyBody)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 22)
                }

                Button {
                    showUnpairAlert = true
                } label: {
                    Text("Unpair partner")
                }
                .buttonStyle(.luckyDestructive)
                .luckyLoading(isUnpairing)
                .padding(.trailing, Outline.shadowOffset)
                .alert("Unpair Partner", isPresented: $showUnpairAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Unpair", role: .destructive) {
                        Task {
                            isUnpairing = true
                            unpairError = await viewModel.unpair()
                            isUnpairing = false
                            // Dashboard and Profile reload, so they stop showing the partner.
                            if unpairError == nil { appState.coupleChanged() }
                        }
                    }
                } message: {
                    Text("Are you sure you want to unpair from \(viewModel.couple?.partner?.firstName ?? "your partner")? Your shared dates will be hidden for both of you, and you'll need to pair again to reconnect.")
                }
                .alert(
                    "Couldn't unpair",
                    isPresented: Binding(
                        get: { unpairError != nil },
                        set: { if !$0 { unpairError = nil } }
                    )
                ) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(unpairError ?? "")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 90)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

struct NoPartnerView: View{
    /// Opens the screen to type the pairing code a partner shared.
    var onEnterCode: () -> Void = {}

    var body: some View {

        WhiteCard(title: "You are not paired", description:"You haven’t connected with your partner yet. Pair up to view your relationship details, track milestones, and plan meaningful moments together.") {


            NavigationLink("Invite my partner") {
                ShareCodePairingView(showsNext: false)
            }
            .buttonStyle(.luckyPrimary)
            .padding(.top, Spacing.l)

            Button("I have a pairing code", action: onEnterCode)
                .buttonStyle(.luckySecondary)

        }

    }
}

#Preview {
    AboutRelationshipView()
        .environment(AppState())
}
